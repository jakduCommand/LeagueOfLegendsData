//
//  ItemModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/27/25.
//

struct ItemModel: Codable {
    let type: String
    let version: String
    let data: [String: ItemDetail]
}

struct ItemDetail: Codable {
    let name: String
    let plaintext: String?
    let description: String?
    let tags: [String]?
    let into: [String]?
    let from: [String]?
    let depth: Int?
    let maps: [String: Bool]?
    let inStore: Bool?
    let gold: GoldInfo
}

struct GoldInfo: Codable {
    let base: Int
    let purchasable: Bool
    let sell: Int
    let total: Int
}
