//
//  MatchViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 2/13/26.
//
import Foundation
import Combine

@MainActor
final class MatchViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var matchIDs: [String]? = []
    
    private let fileService = LeagueFileService()
    private let matchIDService: MatchIDServicing
    private let limiter = RiotRateLimiter()
    
    init (matchIDService: MatchIDServicing) {
        self.matchIDService = matchIDService
    }
    
    func getMatchIds(server: Server, tier: TierSelection) async {
        let file = await getDirectoryURL(server: server, tier: tier)
        await fetchMatchIds(from: file, server: server, tier: tier)
    }
    
    func fetchMatchIds(from file: URL, server: Server, tier: TierSelection) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        var seen = Set<String>()
        var result: [String] = []
        
        let type = "ranked"
        let maxNum = 100
        let startTime = startTimeMidnightUTC()
        
        do {
            let puuids = try await fileService.getPuuidsRecursively(from: file, format: tier)
            
            for puuid in puuids {
                if result.count >= maxNum { break }
                
                try await limiter.acquire()
                let data = try await matchIDService.fetchMatchIDs (
                    puuid: puuid,
                    server: server,
                    startTime: startTime,
                    endTime: nil,
                    queue: nil,
                    type: type,
                    start: nil,
                    count: nil
                )
                
                // Append while deduplicating
                for id in data {
                    if seen.insert(id).inserted {
                        result.append(id)           // preserves first-seen order
                        if result.count >= maxNum { break }
                    }
                }
                
            }
            
            self.matchIDs = result
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: helper
    func getDirectoryURL(server: Server, tier: TierSelection) async -> URL {
        return await fileService.getDirectory(server: server, tier: tier)
    }
    
    // Midnight UTC of "past 3 days"
    func startTimeMidnightUTC(daysBack: Int = 3) -> Int {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)! // UTC
        
        let now = Date()
        let startOfTodayUTC = cal.startOfDay(for: now)
        let start = cal.date(byAdding: .day, value: -daysBack, to: startOfTodayUTC)!
        return Int(start.timeIntervalSince1970) // second
    }
}
