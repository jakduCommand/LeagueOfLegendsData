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
    
    private let service: ChampionListServicing
    
    init(service: ChampionListServicing) {
        self.service = service
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
            let fetched = try await service.fetchChampionList(version)
            self.championList = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
