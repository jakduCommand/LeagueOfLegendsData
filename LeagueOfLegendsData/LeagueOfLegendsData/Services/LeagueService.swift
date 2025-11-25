//
//  LeagueService.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/5/25.
//
import Foundation

protocol LeagueServicing {
    func fetchLeague(
        _ server:String,
        _ league: String,
        _ queue: String
    ) async throws  -> LeagueListDTO
    
    func fetchLeagueMineral(
        _ server: String,
        _ division: String,
        _ tier: String,
        _ queue: String,
        _ page: Int
    ) async throws -> LeagueEntriesDTO
}

struct LeagueService: LeagueServicing {
    func fetchLeague(
        _ server: String,
        _ league: String,
        _ queue: String
    ) async throws -> LeagueListDTO {
        
        guard let apiKey = KeychainService.load() else {
            throw APIKeyError.missingKey
        }
        
        guard let url = URL(string: "https://\(server).api.riotgames.com/lol/league/v4/\(league)/by-queue/\(queue)?api_key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("en-US,en;q=0.", forHTTPHeaderField: "Accept-Language")
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Accept-Charset")
        request.setValue("https://developer.riotgames.com", forHTTPHeaderField: "Origin")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(LeagueListDTO.self, from: data)
    }
    
    func fetchLeagueMineral(
        _ server: String,
        _ division: String,
        _ tier: String,
        _ queue: String,
        _ page: Int
    ) async throws -> LeagueEntriesDTO {
        
        guard let apiKey = KeychainService.load() else {
            throw APIKeyError.missingKey
        }
        
        guard let url = URL(string: "https://\(server).api.riotgames.com/lol/league/v4/entries/\(queue)/\(tier)/\(division)?page=\(page)&api_key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Accept-Charset")
        request.setValue("https://developer.riotgames.com", forHTTPHeaderField: "Origin")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(LeagueEntriesDTO.self, from: data)
    }
}
