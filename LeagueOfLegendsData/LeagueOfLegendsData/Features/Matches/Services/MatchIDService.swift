//
//  MatchIDService.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/30/25.
//
import Foundation

protocol MatchIDServicing {
    func fetchMatchIDs (
        puuid: String,
        server: Server,
        startTime: Int?,
        endTime: Int?,
        queue: Int?,
        type: String?,
        start: Int?,
        count: Int?
        
    ) async throws -> [String]
}

/**
 * Parameters
 * - Start Time: Epoch timestamp in seconds. The matchlist started storing timestamps on June 16th, 2021.
 * Any matches played before June 16th, 2021 won't be included in the results if the startTime filter is set.
 * - End Time: Epoch timestamp in seconds.
 * - Queue: Filter the list of match ids by a specific queue id. This filter is mutually inclusive of the type filter
 * meaning any match ids returned must match both the queue and type filters.
 * - Type: Filter the list of match ids by the type of match. This filter is mutually inclusive of the queue filter
 * meaning any match ids returned must match both the queue and type filters.
 * - Start: Defaults to 0. Start index
 * - Count: Defaults to 20. Valid values: 0 to 100. number of match ids to return.
 */
struct MatchIDService: MatchIDServicing {
    private func region (for platform: Server) -> String {
        switch platform {
        case .NA1, .BR1, .LA1, .LA2, .OC1:
            return "americas"
        case .KR, .JP1:
            return "asia"
        case .EUN1, .EUW1, .TR1, .RU:
            return "europe"
        case .SG2, .TW2, .VN2:
            return "sea"
        default:
            return "americas"
        }
    }
    
    func fetchMatchIDs (
        puuid: String,
        server: Server,
        startTime: Int?,
        endTime: Int?,
        queue: Int?,
        type: String?,
        start: Int?,
        count: Int?
    ) async throws -> [String] {
        
        guard let apiKey = KeychainService.load() else {
            throw APIKeyError.missingKey
        }
        
        let region = self.region(for: server)
        
        var components = URLComponents(string: "https://\(region).api.riotgames.com/lol/match/v5/matches/by-puuid/\(puuid)/ids")!
        
        var queryItems: [URLQueryItem] = []
        if let startTime = startTime { queryItems.append(.init(name: "startTime", value: "\(startTime)")) }
        if let endTime = endTime { queryItems.append(.init(name: "endTime", value: "\(endTime)")) }
        if let queue = queue { queryItems.append(.init(name: "queue", value: "\(queue)")) }
        if let type = type { queryItems.append(.init(name: "type", value: type)) }
        if let start = start { queryItems.append(.init(name: "start", value: "\(start)")) }
        if let count = count { queryItems.append(.init(name: "count", value: "\(count)")) }
        queryItems.append(.init(name: "api_key", value: apiKey))
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpsResp = response as? HTTPURLResponse, (200...299).contains(httpsResp.statusCode) else {
            if let badResp = (response as? HTTPURLResponse) {
                let url = badResp.url ?? URL(string: "Unknown URL")!
                throw NetworkError.badResponse(url: url, statusCode: badResp.statusCode)
            } else {
                throw URLError(.badServerResponse)
            }
        }
        
        return try JSONDecoder().decode([String].self, from: data)
    }
}
