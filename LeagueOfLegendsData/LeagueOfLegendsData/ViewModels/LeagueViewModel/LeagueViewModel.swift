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
    @Published var isSaving = false
    @Published var leagueListDTO: LeagueListDTO?
    @Published var leagueEntriesDTO: LeagueEntriesDTO?
    @Published var progressText: String?
    
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
    
    // MARK: - Save entries. Distinguish the tier and call
    // Call appropirate save function for each tier
    // saveEntriesHigh: Master - Challenger
    // saveEntriesLow: Iron - Diamond
    func save(
        server: Server,
        queue: RankQueue,
        tier: TierSelection,
        division: Division?,
        page: Int?
    ) async {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        
        do {
            switch tier {
                
            case .high(let highTier):
                guard let data = leagueListDTO else {
                    errorMessage = "No data to save high tier entries"
                    return
                }
                
                try await fileService.saveHighTier (
                   data,
                   server,
                   highTier,
                   queue
                )
                
            case .low(let lowTier):
                guard let data = leagueEntriesDTO else {
                    errorMessage = "No data to save low tier entries"
                    return
                }
                
                guard let division, let page else {
                    errorMessage = "Division and page are required for low tiers."
                    return
                }
                
                try await fileService.saveLowTier (data, server, division, lowTier, queue, page)
            }
        } catch is CancellationError {
            // If user changes selection quickly, ignore cancellation.
        } catch APIKeyError.missingKey {
            errorMessage = "Please enter your API key in Settings."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    

    // MARK: - Save all entries
    func saveAll() {
        isSaving = true
        errorMessage = nil
        let engine = LeagueSaveAllEngine(service: service, fileService: fileService)
        
        Task { [weak self] in
            guard let self else { return }
            defer { self.isSaving = false }
            
            do {
                try await engine.saveAll(
                    servers: Server.allCases,
                    queues: RankQueue.allCases,
                    lowPages: 1...10
                ) { [weak self] done, total in
                    await MainActor.run {
                        self?.progressText = "\(done)/\(total)"
                    }
                }
            } catch is CancellationError {
                
            } catch APIKeyError.missingKey {
                self.errorMessage = "Please enter your API key in Settings."
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
