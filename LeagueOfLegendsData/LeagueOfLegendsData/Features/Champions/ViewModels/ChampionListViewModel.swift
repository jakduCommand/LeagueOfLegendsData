//
//  ChampionListViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/4/25.
//
import Foundation
import Combine

@MainActor
final class ChampionListViewModel: ObservableObject {
    @Published var championList: ChampionListModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var samples: [ChampionMatchSample] = []
    
    private let championListService: ChampionListServicing
    private let itemService: ItemServicing
    private let leagueFileService: LeagueFileService
    private let builder: ChampionMatchSampleBuilder
    
    init(championListService: ChampionListServicing, itemService: ItemServicing, leagueFileService: LeagueFileService) {
        self.championListService = championListService
        self.itemService = itemService
        self.leagueFileService = leagueFileService
        self.builder = ChampionMatchSampleBuilder()
    }
    
    func buildChampionLookup(_ championList: ChampionListModel) -> [String: ChampionListData] {
        var lookup: [String: ChampionListData] = [:]
        for champ in championList.data.values {
            let key = champ.id.lowercased().filter { $0.isLetter }
            lookup[key] = champ
        }
        return lookup
    }
    
    func getChampionList() -> [String] {
        guard let championList = championList else { return [] }
        return championList.data.keys.sorted()
    }
    
    func load(_ version: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetched = try await championListService.fetchChampionList(version)
            self.championList = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func buildChampionMathSample(
        version: String,
        server: Server?,
        tier: TierSelection?,
        matchId: String
    ) {
        isLoading = true
        errorMessage = nil
        
        let id = matchId.isEmpty ? nil : matchId
        Task {
            do {
                let samples = try await builder.build(
                    version: version,
                    server: server,
                    tier: tier,
                    matchId: id
                )
                
                self.samples = samples
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            self.isLoading = false
        }
    }
}
