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
struct PackingItem: Codable{
    var title: String
    var isChecked: Bool
}

//行程
struct TripEvent{
    var time: String
    var title: String
    var location: String
}
