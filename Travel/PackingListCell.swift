//
//  PackingListCell.swift
//  Travel
//
//  Created by 古峻瑋 on 2026/1/5.
//

import UIKit

class PackingListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!   // 顯示品項名稱
    @IBOutlet weak var checkButton: UIButton! // 那個打勾按鈕
    
    // 定義一個動作，讓 ViewController 知道按鈕被按了
    var toggleAction: (() -> Void)?

    // 設定畫面的函式 (給 ViewController 呼叫用)
    func configure(name: String, isDone: Bool) {
        
        // 處理刪除線邏輯
        if isDone {
            // 如果已完成：加上刪除線
            let attributeString = NSMutableAttributedString(string: name)
            attributeString.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributeString.length))
            nameLabel.attributedText = attributeString
            
            // 換成實心勾勾圖案
            checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            // 如果未完成：清除刪除線
            nameLabel.attributedText = nil
            nameLabel.text = name
            
            // 換回空心方塊圖案
            checkButton.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }
    
    // 按鈕點擊事件
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        // 呼叫上面的動作，通知 ViewController
        toggleAction?()
    }
}
