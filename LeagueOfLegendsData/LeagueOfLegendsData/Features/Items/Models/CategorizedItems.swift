//
//  CategorizedItems.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/3/25.
//

struct CategorizedItems {
    var items: [Int: ItemDetail] = [:]
    var boots: Set<Int> = []
    var trinkets: Set<Int> = []
    var consumables: Set<Int> = []
    var starters: Set<Int> = []
    var completed: Set<Int> = []
    var legendary: Set<Int> = []
    var mythic: Set<Int> = []
    var advancedBoots: Set<Int> = []
    var basic: Set<Int> = []
    var epic: Set<Int> = []
}

extension CategorizedItems {
    var allCategories: [String: Set<Int>] {
        [
            "Boots": boots,
            "Trinkets": trinkets,
            "Consumables": consumables,
            "Starters": starters,
            "Legendary": legendary,
            "AdvancedBoots": advancedBoots,
            "Basic": basic,
            "Epic": epic
        ]
    }
}
