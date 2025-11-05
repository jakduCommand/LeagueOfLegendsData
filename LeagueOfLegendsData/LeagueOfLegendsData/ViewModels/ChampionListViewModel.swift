//
//  ChampionListViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/4/25.
//
import Foundation
import Combine

@MainActor
final class ChampionListViewModel {
    @Published var championList: ChampionListModel?
    
    private let service: ChampionListServicing
    
    init(service: ChampionListServicing) {
        self.service = service
    }
    
    func load() {
        
    }
}
