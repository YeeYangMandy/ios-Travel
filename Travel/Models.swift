//
//  Models.swift
//  Travel
//
//  Created by EB209 on 2025/12/25.
//

import Foundation

//信用卡
struct CreditCard{
    let name: String
    let foreignCashback: Double //海外回饋
    let handlingFee: Double = 0.015 //海外手續費
}

//打包清單
// 加上 Codable 才能存進 UserDefaults
struct PackingItem: Codable {
    var name: String
    var isDone: Bool      // 這個屬性來記錄狀態
    var isChecked: Bool
    var isDisabled: Bool  // 暫時關閉
}

//行程
struct TripEvent {
    var date: Date // 改用 Date 類型，方便排序和格式化
    var title: String
    var location: String // 存地址
}
