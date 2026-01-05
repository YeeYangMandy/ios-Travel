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
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var resultTextView: UITextView!
    
    // Data
        let currencies = ["JPY（日幣）", "USD（美金）", "KRW（韓元）", "EUR（歐元）"]
        let exchangeRates: [String: Double] = ["JPY": 0.22, "USD": 31.5, "KRW": 0.024, "EUR": 34.2]
        
        let cards = [
            CreditCard(name: "現金（無回饋）", foreignCashback: 0.0),
            CreditCard(name: "聯邦吉鶴卡（3.5%）", foreignCashback: 0.035),
            CreditCard(name: "富邦Ｊ卡（3%）", foreignCashback: 0.03),
            CreditCard(name: "國泰CUBE（3%）", foreignCashback: 0.03)
        ]
        
        var selectedCurrencyIndex = 0
        
        override func viewDidLoad() {
            super.viewDidLoad()
            pickerView.delegate = self
            pickerView.dataSource = self
            
            // 清空結果欄位
            resultLabel.text = "請輸入金額並計算"
            resultTextView.text = ""
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
        }
        
        @objc func dismissKeyboard(){
            view.endEditing(true)
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return currencies.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return currencies[row]
        }
        
        @IBAction func calculateTapped(_ sender: UIButton) {
            guard let text = amountTextField.text, let amount = Double(text) else {
                resultLabel.text = "請輸入正確數字"
                return
            }
            
            let selectedCurrencyRow = pickerView.selectedRow(inComponent: 0)
            let currencyKey = String(currencies[selectedCurrencyRow].prefix(3)) // "JPY"
            let rate = exchangeRates[currencyKey] ?? 1.0
            
            // 顯示基本資訊
            let baseTWD = amount * rate
            resultLabel.text = "原始金額約：\(Int(baseTWD)) TWD (匯率 \(rate))"
            
            var outputMessage = ""
            
            for card in cards {
                let handlingFeeRate = card.name.contains("現金") ? 0.0 : 0.015
                
                let fee = baseTWD * handlingFeeRate
                let cashback = baseTWD * card.foreignCashback
                let finalCost = baseTWD + fee - cashback
                
                outputMessage += "──────────────\n"
                outputMessage += "💳 \(card.name)\n"
                outputMessage += "手續費: +\(Int(fee)) | 回饋: -\(Int(cashback))\n"
                outputMessage += "最終金額: NT$ \(Int(finalCost))\n"
                outputMessage += "\n"
            }
            
            resultTextView.text = outputMessage
            
            dismissKeyboard()
        }
}
