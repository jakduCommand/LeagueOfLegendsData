//
//  ChampionListModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/4/25.
//

struct ChampionListModel: Decodable {
    let data: [String: ChampionListData]
}

struct ChampionListData: Decodable {
    let version: String
    let id: String
    let key: String
    let name : String
}


