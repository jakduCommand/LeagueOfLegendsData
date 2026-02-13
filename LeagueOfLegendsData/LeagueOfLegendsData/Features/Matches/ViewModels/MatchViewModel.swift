//
//  MatchViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 2/13/26.
//
import Foundation
import Combine

@MainActor
final class MatchViewModel {
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    
    private let fileService = LeagueFileService()
    
    func getMatches(from file: URL, tier: TierSelection) async -> [String] {
        var puuids: [String] = []
        
        do {
            puuids = try await fileService.getPuuids(from: file, format: tier)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        return puuids
    }
}
