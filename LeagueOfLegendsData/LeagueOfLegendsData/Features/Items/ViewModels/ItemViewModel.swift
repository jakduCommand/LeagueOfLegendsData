//
//  ItemViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/27/25.
//
import Foundation
import Combine

@MainActor
final class ItemViewModel: ObservableObject {
    @Published var itemModel: ItemModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: ItemServicing
    
    // Raw map for any extra info you might need later
    private var items: [Int: ItemDetail] = [:]
    
    // Category sets
    private var categorizedItems = CategorizedItems()
    
    init(service: ItemServicing) {
        self.service = service
    }
    
    // Convenient checks
    func isBoots(_ id: Int) -> Bool { categorizedItems.boots.contains(id) }
    func isAdvancedBoots(_ id: Int) -> Bool { categorizedItems.advancedBoots.contains(id) }
    func isTrinket(_ id: Int) -> Bool {
        categorizedItems.trinkets.contains(id)
    }
    func isConsumable(_ id: Int) -> Bool {
        categorizedItems.consumables.contains(id)
    }
    func isStarter(_ id: Int) -> Bool {
        categorizedItems.starters.contains(id)
    }
    func isCompleted(_ id: Int) -> Bool {
        categorizedItems.completed.contains(id)
    }
    func isLegendary(_ id: Int) -> Bool {
        categorizedItems.legendary.contains(id)
    }
    func isMythic(_ id: Int) -> Bool {
        categorizedItems.mythic.contains(id)
    }
    
    func getItems() -> CategorizedItems {
        return self.categorizedItems
    }
    
    func load(_ version: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetched = try await service.fetchItems(version)
            
            let categorized = await Task.detached(priority: .userInitiated) {
                ItemCategorizer.categorize(fetched.data)
            }.value
            
            self.categorizedItems = categorized
            
            self.itemModel = fetched
            self.errorMessage = nil
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
