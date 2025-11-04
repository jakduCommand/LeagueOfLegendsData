//
//  ItemService.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/28/25.
//
import Foundation

protocol ItemServicing {
    func fetchItems(_ version: String) async throws -> ItemModel
}

struct ItemService: ItemServicing {
    func fetchItems(_ version: String) async throws -> ItemModel {
        let urlString = "https://ddragon.leagueoflegends.com/cdn/\(version)/data/en_US/item.json"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(ItemModel.self, from: data)
    }
}
