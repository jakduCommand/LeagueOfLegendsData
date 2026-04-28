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
    // MARK: - Variables
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var matchIDs: [String] = []
    
    @Published var saveAllCurrent: Int = 0
    @Published var saveAllTotal: Int = 0
    @Published var saveAllLabel: String = ""
    
    var saveAllProgress: Double {
        guard saveAllTotal > 0 else { return 0 }
        return Double(saveAllCurrent) / Double(saveAllTotal)
    }
    
    var hasMatchIDs: Bool {
        return !(matchIDs.isEmpty)
    }
    
    private let fileService = LeagueFileService()
    private let matchIDService: MatchIDServicing
    private let limiter = RiotRateLimiter()
    
    init (matchIDService: MatchIDServicing) {
        self.matchIDService = matchIDService
    }
    
    // MARK: - Getter
    func getMatchIds(server: Server, tier: TierSelection) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let result = try await fetchMatchIds(server: server, tier: tier)
            self.matchIDs = result
        } catch {
            errorMessage = error.localizedDescription
        }    }
    
    func getMatchTimelineDto(server: Server, tier: TierSelection, count: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        var failed: [String] = []
        
        guard let mCount = Int(count), (1...100).contains(mCount) else {
            return
        }
        
        do {
            let matchIDs = try await readMatchIDs(server: server, tier: tier)
            
            for i in 0..<mCount {
                let matchID = matchIDs[i]
                do {
                    let (matchDto, timelineDto) = try await fetchMatchTimelineDto(server: server, tier: tier, matchID: matchID)
                    try await saveMatchTimelineDto(matchDto, timelineDto, server, tier)
                } catch is CancellationError {
                    return
                } catch {
                    failed.append(matchID)
                }
            }
            
            if !failed.isEmpty {
                errorMessage = "Failed to fetch \(failed.count) match(es)"
            }
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Fetch
    func fetchMatchIds(server: Server, tier: TierSelection) async throws -> [String] {
        let file = await getDirectoryURL(server: server, tier: tier)
        
        var seen = Set<String>()
        var result: [String] = []
        
        let type = "ranked"
        let maxNum = 100
        let startTime = startTimeMidnightUTC()
        
        
        let puuids = try await fileService.getPuuidsRecursively(from: file, format: tier)
        
        for puuid in puuids {
            if result.count >= maxNum { break }
            
            try await limiter.acquire()
            let data = try await matchIDService.fetchMatchIDs (
                puuid: puuid,
                server: server,
                startTime: startTime,
                endTime: nil,
                queue: 420,
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
        
        return result
    }
    
    func fetchMatchTimelineDto(server: Server, tier: TierSelection, matchID: String) async throws -> (MatchDto, TimelineDto) {
        
        try await limiter.acquire()
        let matchDto = try await matchIDService.fetchMatchDto(matchID: matchID, server: server)
        
        try await limiter.acquire()
        let timelineDto = try await matchIDService.fetchTimelineDto(matchID: matchID, server: server)
        
        return (matchDto, timelineDto)
    }
    
    // MARK: - Read
    func readMatchIDs(server: Server, tier: TierSelection) async throws -> [String] {
        return try await fileService.getMatchIDs(server: server, tier: tier)
    }
    
    // MARK: - Save
    func save(
        _ server: Server,
        _ tier: TierSelection
    ) async {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        
        guard !matchIDs.isEmpty else {
            errorMessage = "No match IDs"
            return
        }
        
        do {
            try await fileService.saveMatchID(
                matchIDs,
                server,
                tier
            )
        } catch is CancellationError {
            // If user changes selection quickly, ignore cancellation.
        } catch {
            errorMessage = error.localizedDescription
        }
        
    }
    
    func saveAll(server: Server) async {
        errorMessage = nil
        isSaving = true
        
        let tiers = TierSelection.allCases
        saveAllTotal = tiers.count
        saveAllCurrent = 0
        saveAllLabel = "Preparing..."
        
        defer { isSaving = false }
        
        do {
            for (index, tier) in tiers.enumerated() {
                saveAllLabel = "Saving \(tier.display)"
                
                let matchIDs = try await fetchMatchIds(server: server, tier: tier)
                try await fileService.saveMatchID(matchIDs, server, tier)
                
                saveAllCurrent = index + 1
                self.matchIDs = matchIDs
            }
        } catch is CancellationError {
            // ignore cancellation
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func saveMatchTimelineDto(_ matchDto: MatchDto, _ timelineDto: TimelineDto, _ server: Server, _ tier: TierSelection) async throws {
        try await fileService.saveMatchDtoTimeline(matchDto, timelineDto, server, tier)
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
