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
            CreditCard(name: "現金（無回饋）", foreignCashback: 0.0), // handlingFee 預設 0
            CreditCard(name: "聯邦吉鶴卡（3.5%）", foreignCashback: 0.035),
            CreditCard(name: "富邦Ｊ卡（3%）", foreignCashback: 0.03),
            CreditCard(name: "國泰CUBE（3%）", foreignCashback: 0.03)
        ]
        
        // 變數
        var selectedCurrencyIndex = 0
        // var selectedCardIndex = 0  <-- 這個不需要了，因為我們要一次算全部
        
        override func viewDidLoad() {
            super.viewDidLoad()
            pickerView.delegate = self
            pickerView.dataSource = self
            
            // 預設清空結果欄位
            resultLabel.text = "請輸入金額並計算"
            resultTextView.text = ""
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
        }
        
        @objc func dismissKeyboard(){
            view.endEditing(true)
        }
        
        // MARK: - PickerView Logic
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1 // 🔥 修改：改成 1 欄就好，因為我們只需要選「幣別」，卡片會全部列出來
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return currencies.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return currencies[row]
        }
        
        // MARK: - Actions
        @IBAction func calculateTapped(_ sender: UIButton) {
            // 1. 檢查輸入
            guard let text = amountTextField.text, let amount = Double(text) else {
                resultLabel.text = "請輸入正確數字"
                return
            }
            
            // 2. 獲取選中的貨幣
            let selectedCurrencyRow = pickerView.selectedRow(inComponent: 0)
            let currencyKey = String(currencies[selectedCurrencyRow].prefix(3)) // "JPY"
            let rate = exchangeRates[currencyKey] ?? 1.0
            
            // 顯示基本資訊
            let baseTWD = amount * rate
            resultLabel.text = "原始金額約：\(Int(baseTWD)) TWD (匯率 \(rate))"
            
            // 3. 🔥 核心修改：用迴圈計算所有卡片，並串接字串
            var outputMessage = ""
            
            for card in cards {
                // 判斷手續費 (如果是現金就 0，卡片通常是 1.5% = 0.015)
                // 注意：這裡假設你的 CreditCard struct 有 handlingFee，如果沒有，手動判斷
                let handlingFeeRate = card.name.contains("現金") ? 0.0 : 0.015
                
                let fee = baseTWD * handlingFeeRate
                let cashback = baseTWD * card.foreignCashback
                let finalCost = baseTWD + fee - cashback
                
                // 串接顯示文字
                outputMessage += "──────────────\n"
                outputMessage += "💳 \(card.name)\n"
                outputMessage += "手續費: +\(Int(fee)) | 回饋: -\(Int(cashback))\n"
                outputMessage += "最終金額: NT$ \(Int(finalCost))\n"
                outputMessage += "\n"
            }
            
            // 4. 把串好的長字串，丟給 Text View 顯示
            resultTextView.text = outputMessage
            
            // 收起鍵盤
            dismissKeyboard()
        }
}
