//
//  GetChampionList.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/16/25.
//
import Foundation

func buildChampionLookup(_ championList: ChampionListModel) -> [String: ChampionListData] {
    var lookup: [String: ChampionListData] = [:]
    for champ in championList.data.values {
        let key = champ.id.lowercased().filter { $0.isLetter }
        lookup[key] = champ
    }
    return lookup
}
