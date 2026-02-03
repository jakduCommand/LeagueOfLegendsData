//
//  VersionService.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/28/25.
//
import Foundation

protocol VersionServicing {
    func fetchVersions() async throws -> [String]
}

struct VersionService: VersionServicing {
    func fetchVersions() async throws -> [String] {
        let urlString = "https://ddragon.leagueoflegends.com/api/versions.json"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResp = response as? HTTPURLResponse, (200...299).contains(httpResp.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([String].self, from: data)
    }
}
