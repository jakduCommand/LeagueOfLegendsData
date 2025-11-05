//
//  ChampionListService.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/4/25.
//
import Foundation

protocol ChampionListServicing {
    func fetchChampionList(_ version: String) async throws -> ChampionListModel
}

struct ChampionListService: ChampionListServicing {
    func fetchChampionList(_ version: String) async throws -> ChampionListModel {
        let urlString = "https://ddragon.leagueoflegends.com/cdn/\(version)/data/en_US/champion.json"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResp = response as? HTTPURLResponse, (200...299).contains(httpResp.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let championListResponse = try decoder.decode(ChampionListModel.self, from: data)
        
        return championListResponse
    }
}
