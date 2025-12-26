//
//  CalculatorViewController.swift
//  Travel
//
//  Created by EB209 on 2025/12/25.
//

import UIKit

class CalculatorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView
    
    //Mark: Data 先用測試資料，之後接API
    let currencies = ["JPY（日幣）", "USD（美金）", "KRW（韓元）", "EUR（歐元）"]
    let exchangeRates: [String: Double] = ["JPY": 0.22, "USD": 31.5, "KRW": 0.024, "EUR": 34.2]
    let cards = [
        CreditCard(name: "現金（無回饋）", foreignCashback: 0.0),
        CreditCard(name: "聯邦吉鶴卡（3.5%）", foreignCashback: 0.035),
        CreditCard(name: "富邦Ｊ卡（3%）", foreignCashback: 0.03),
        CreditCard(name: "國泰CUBE（3%）", foreignCashback: 0.03)
    ]
    
    var selectedCurrencyIndex = 0
    var selectedCardIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    //Mark: pickerview logic
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? currencies.count : cards.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? currencies[row] : cards[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {selectedCurrencyIndex = row}
        else{selectedCardIndex = row}
    }
    
    //Mark: Actions (連線Button)
    @IBAction func calculateTapped(_ sender: UIButton){
        guard let text = amountTextField.text, let amount = Double(text) else{
            resultLabel.text = "請輸入正確金額"
            return
        }
        let currencyKey = String(currencies[selectedCurrencyIndex].prefix(3))
        let rate = exchangeRates[currencyKey] ?? 1.0
        let card = cards[selectedCardIndex]
        
        let baseTWD = amount * rate
        let fee = (card.name.contains("現金")) ? 0 : baseTWD * card.handlingFee
        let cashback = baseTWD * card.foreignCashback
        let finalCost = baseTWD + fee - cashback
        
        //顯示結果
        resultLabel.text = """
        原始折合：NT$ \(Int(baseTWD))
        + 手續費：NT$ \(Int(fee))
        - 回饋金：NT$ \(Int(cashback))
        --------------
        實際成本：NT$ \(Int(finalCost))
        """
    }
}
