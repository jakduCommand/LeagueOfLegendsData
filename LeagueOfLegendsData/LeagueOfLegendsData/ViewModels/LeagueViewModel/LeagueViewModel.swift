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
    @Published var leagueListDTO: LeagueListDTO?
    @Published var leagueEntriesDTO: LeagueEntriesDTO?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let service: LeagueServicing
    
    init(service: LeagueServicing) {
        self.service = service
    }
    
    // Fetch Challenger-Master tier user list
    func getLeagueList(
        _ server:String,
        _ league: String,
        _ queue: String
    ) async {
        do {
            self.isLoading = true
            defer { self.isLoading = false }
            
            let result = try await self.service.fetchLeague(server, league, queue)
            
            self.leagueEntriesDTO = nil
            self.errorMessage = nil
            self.leagueListDTO = result
        } catch APIKeyError.missingKey {
            errorMessage = "Please enter your API key in Settings."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Fetch Iron-Diamond tier user list
    func getLeagueEntries(
        _ server: String,
        _ division: String,
        _ tier: String,
        _ queue: String,
        _ page: Int
    ) async {
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
    
            self.leagueEntriesDTO = nil
            self.errorMessage = nil
            self.leagueEntriesDTO = result
        } catch APIKeyError.missingKey {
            errorMessage = "Please enter your API kye in Settings."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
