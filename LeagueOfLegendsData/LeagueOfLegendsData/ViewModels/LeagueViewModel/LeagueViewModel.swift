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
    
    private let service: LeagueServicing
    private let fileService: LeagueFileService
    
    init(service: LeagueServicing, fileService: LeagueFileService) {
        self.service = service
        self.fileService = fileService
    }
    
    // Fetch Challenger-Master tier user list
    func getLeagueList(
        _ server:String,
        _ league: String,
        _ queue: String
    ) async throws -> LeagueListDTO? {
        do {
            self.isLoading = true
            defer { self.isLoading = false }
            
            let result = try await self.service.fetchLeague(server, league, queue)
            
            self.errorMessage = nil
            
            return result
        } catch APIKeyError.missingKey {
            errorMessage = "Please enter your API key in Settings."
        } catch {
            errorMessage = error.localizedDescription
        }
        return nil
    }
    
    // Fetch Iron-Diamond tier user list
    func getLeagueEntries(
        _ server: String,
        _ division: String,
        _ tier: String,
        _ queue: String,
        _ page: Int
    ) async throws -> LeagueEntriesDTO? {
        do {
            self.isLoading = true
            defer { self.isLoading = false }
            
            let result = try await self.service.fetchLeagueMineral (
                server,
                division,
                tier,
                queue,
                page
            )
            
            self.errorMessage = nil
            
            return result
        } catch APIKeyError.missingKey {
            errorMessage = "Please enter your API kye in Settings."
        } catch {
            errorMessage = error.localizedDescription
        }
        return nil
    }
    
    // MARK: - Save entries(Low tiers)
    func saveEntries(
        _ server: String,
        _ division: String,
        _ tier: String,
        _ queue: String,
        _ page: Int) {
        
    }
    
    // MARK: - Save All pages for lower tiers
    func saveAllPages(
        _ server: String,
        _ division: String,
        _ tier: String,
        _ queue: String
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        var page = 1
        let maxPages = 200
        
        while page <= maxPages {
            do {
                guard let entries = try await getLeagueEntries(
                    server,
                    division,
                    tier,
                    queue,
                    page
                ) else {
                    break
                }
                
                // empty array = no more pages
                if entries.isEmpty { break }
                
                await fileService.saveEntries(entries, server, division, tier, queue, "\(page)")
                page += 1
            } catch {
                errorMessage = error.localizedDescription
                break
            }
        }
    }
}
