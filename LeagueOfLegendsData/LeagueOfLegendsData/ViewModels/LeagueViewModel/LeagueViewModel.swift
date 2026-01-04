//
//  LeagueViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/16/25.
//
import Foundation
import Combine

@MainActor
final class LeagueViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var leagueListDTO: LeagueListDTO?
    @Published var leagueEntriesDTO: LeagueEntriesDTO?
    
    private let service: LeagueServicing
    private let fileService: LeagueFileService
    
    init(service: LeagueServicing, fileService: LeagueFileService) {
        self.service = service
        self.fileService = fileService
    }
    
    // Fectch player list of selected tier
    func fetch (
        server: Server,
        queue: RankQueue,
        tier: TierSelection,
        division: Division?,
        page: Int?
    ) async {
        // Rest UI state for a new request
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        leagueEntriesDTO = nil
        leagueListDTO = nil
        
        do {
            
            switch tier {
            case .high(let highTier):
                let result = try await service.fetchHighTier(server, highTier, queue)
                leagueListDTO = result
                leagueEntriesDTO = nil
                
            case .low(let lowTier):
                guard let division, let page else {
                    errorMessage = "Division and page are required for low tiers."
                    return
                }
                let result = try await service.fetchLowTier(server, division, lowTier, queue, page)
                leagueEntriesDTO = result
                leagueListDTO = nil
            }
        } catch is CancellationError {
            // If user changes selection quickly, ignore cancellation.
        } catch APIKeyError.missingKey {
            errorMessage = "Please enter your API key in Settings."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Save entries(Low tiers)
    func saveEntriesLow(
        _ server: String,
        _ division: String,
        _ tier: String,
        _ queue: String,
        _ page: Int
    ) async {
        guard let dto = leagueEntriesDTO else { return }
        
        do {
            try await fileService.saveEntries(
                dto,
                server,
                division,
                tier,
                queue,
                "\(page)"
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Save entries(High tiers)
    func saveEntriesHigh(
        _ server: String,
        _ tier: String,
        _ queue: String,
    ) async {
        guard let dto = leagueListDTO else { return }
        
        do {
            try await fileService.saveTopTierEntries(
               dto,
               server,
               tier,
               queue
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Save entries. Distinguish the tier and call
    // Call appropirate save function for each tier
    // saveEntriesHigh: Master - Challenger
    // saveEntriesLow: Iron - Diamond
    func save(
        server: Server,
        queue: RankQueue,
        tier: TierSelection,
        division: Division,
        page: Int
    ) {
        
    }
    // MARK: - Save all entries
    func saveAllEntries() async {
        
    }
}
