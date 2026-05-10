//
//  ItemAnalyzer.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 4/30/26.
//

struct ItemAnalyzer {
    
    private let categorizedItems: CategorizedItems
    
    init(_ data: [String: ItemDetail]) {
        self.categorizedItems = ItemCategorizer.categorize(data)
    }
    
    private let bootItemIds: Set<Int> = [
        3006,   // Berserker's Greaves
        3047,   // Plated Steelcaps
        3111,   // Mercury's Treads
        3020,   // Sorcerer's Shoes
        3158,   // Ionian Boots
        3117,   // Mobility Boots
        3009    // Boots of Swiftness
    ]
    
    func starterItems(from events: [EventsTimeLineDto]) -> [Int] {
        events
            .filter { $0.type == "ITEM_PURCHASED" }
            .filter { $0.timestamp <= 120_000 }
            .compactMap { $0.itemId }
    }
    
    func coreItems(from events: [EventsTimeLineDto]) -> [Int] {
        events
            .filter { $0.type == "ITEM_PURCHASED" }
            .compactMap { $0.itemId }
            .filter { categorizedItems.isLegendary($0) }
    }
    
    func boots(from events: [EventsTimeLineDto]) -> Int? {
        let purchasedBoot = events
            .filter { $0.type == "ITEM_PURCHASED" }
            .compactMap { $0.itemId }
            .first { categorizedItems.isBoots($0) }
        
        return purchasedBoot
    }
}
