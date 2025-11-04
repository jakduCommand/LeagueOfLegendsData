//
//  GetChampionList.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/16/25.
//
import Foundation

struct ChampionList: Decodable {
    let data: [String: ChampionListData]
}

struct ChampionListData: Decodable {
    let version: String
    let id: String
    let key: String
    let name : String
}

func fetchChampionList(_ version: String) async throws -> ChampionList {
    let urlString = "https://ddragon.leagueoflegends.com/cdn/\(version)/data/en_US/champion.json"
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResp = response as? HTTPURLResponse, (200...299).contains(httpResp.statusCode) else {
        throw URLError(.badServerResponse)
    }
    
    let decoder = JSONDecoder()
    let championListResponse = try decoder.decode(ChampionList.self, from: data)
    
    return championListResponse
}

func buildChampionLookup(_ championList: ChampionList) -> [String: ChampionListData] {
    var lookup: [String: ChampionListData] = [:]
    for champ in championList.data.values {
        let key = champ.id.lowercased().filter { $0.isLetter }
        lookup[key] = champ
    }
    return lookup
}
