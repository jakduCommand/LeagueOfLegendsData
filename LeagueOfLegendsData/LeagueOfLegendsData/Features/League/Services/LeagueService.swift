//
//  LeagueService.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/5/25.
//
import Foundation

protocol LeagueServicing {
    func fetchHighTier(
        _ server: Server,
        _ tier: HighTier,
        _ queue: RankQueue
    ) async throws  -> LeagueListDTO
    
    func fetchLowTier(
        _ server: Server,
        _ division: Division,
        _ tier: LowTier,
        _ queue: RankQueue,
        _ page: Int
    ) async throws -> LeagueEntriesDTO
}

struct LeagueService: LeagueServicing {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpMaximumConnectionsPerHost = 1
        return URLSession(configuration: config)
    }()
    
    func fetchHighTier(
        _ server: Server,
        _ tier: HighTier,
        _ queue: RankQueue
    ) async throws -> LeagueListDTO {
        
        guard let apiKey = KeychainService.load() else {
            throw APIKeyError.missingKey
        }
        
        guard let url = URL(string: "https://\(server.rawValue).api.riotgames.com/lol/league/v4/\(tier.rawValue)/by-queue/\(queue.rawValue)?api_key=\(apiKey)") else {
            throw APIError.invalidURL("https://\(server.rawValue).api.riotgames.com/lol/league/v4/\(tier.rawValue)/by-queue/\(queue.rawValue)?api_key=\(apiKey)")
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("en-US,en;q=0.", forHTTPHeaderField: "Accept-Language")
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Accept-Charset")
        request.setValue("https://developer.riotgames.com", forHTTPHeaderField: "Origin")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("Status Code:", httpResponse.statusCode, " URL: ", url)
        
        if !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "No body"
            print("Error body:", body)
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(LeagueListDTO.self, from: data)
    }
    
    func fetchLowTier(
        _ server: Server,
        _ division: Division,
        _ tier: LowTier,
        _ queue: RankQueue,
        _ page: Int
    ) async throws -> LeagueEntriesDTO {
        
        guard let apiKey = KeychainService.load() else {
            throw APIKeyError.missingKey
        }
        
        guard let url = URL(string: "https://\(server.rawValue).api.riotgames.com/lol/league/v4/entries/\(queue.rawValue)/\(tier.rawValue)/\(division.rawValue)?page=\(page)&api_key=\(apiKey)") else {
            throw APIError.invalidURL("https://\(server.rawValue).api.riotgames.com/lol/league/v4/entries/\(queue.rawValue)/\(tier.rawValue)/\(division.rawValue)?page=\(page)&api_key=\(apiKey)")
        }
        
        print(url)
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Accept-Charset")
        request.setValue("https://developer.riotgames.com", forHTTPHeaderField: "Origin")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("Status Code:", httpResponse.statusCode, " URL: ", url)
        
        if !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "No body"
            print("Error body:", body)
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(LeagueEntriesDTO.self, from: data)
    }
    
    
}

