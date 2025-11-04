//
//  ItemCategorizer.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/31/25.
//
import Foundation


nonisolated struct ItemCategorizer {
    static func categorize(_ data: [String: ItemDetail]) -> CategorizedItems {
        var result = CategorizedItems()
        
        for (key, detail) in data {
            guard let id = Int(key) else { continue }
            result.items[id] = detail
            
            let tags = Set(detail.tags ?? [])
            
            // Boots: tag "Boots"
            if tags.contains("Boots"),
               detail.gold.total < 1400,
               detail.gold.total > 300 {
                if isPurchasableNow(detail, id: id) {
                    result.boots.insert(id)
                }
            }
            
            // AdvancedBoots: hardcoding by name
            if detail.name.localizedCaseInsensitiveContains("Armored Advance")
                || detail.name.localizedCaseInsensitiveContains("Chainlaced Crushers")
                || detail.name.localizedCaseInsensitiveContains("Crimson Lucidity")
                || detail.name.localizedCaseInsensitiveContains("Forever Forward")
                || detail.name.localizedCaseInsensitiveContains("Gunmetal Greaves")
                || detail.name.localizedCaseInsensitiveContains("Spellslinger's Shoes")
                || detail.name.localizedCaseInsensitiveContains("Swiftmarch") {
                if isPurchasableNow(detail, id: id) && !result.boots.contains(id){
                    result.advancedBoots.insert(id)
                }
                
            }
            
            if detail.name.localizedStandardContains("Amplifying Tome")
                || detail.name.localizedStandardContains("B. F. Sword")
                || detail.name.localizedStandardContains("Blasting Wand")
                || detail.name.localizedStandardContains("Cloak of Agility")
                || detail.name.localizedStandardContains("Cloth Armor")
                || detail.name.localizedStandardContains("Dagger")
                || detail.name.localizedStandardContains("Faerie Charm")
                || detail.name.localizedStandardContains("Glowing Mote")
                || detail.name.localizedStandardContains("Long Sword")
                || detail.name.localizedStandardContains("Needlessly Large Rod")
                || detail.name.localizedStandardContains("Null-Magic Mantle")
                || detail.name.localizedStandardContains("Pickaxe")
                || detail.name.localizedStandardContains("Rejuvenation Bead")
                || detail.name.localizedStandardContains("Ruby Crystal")
                || detail.name.localizedStandardContains("Sapphire Crystal") {
                if isPurchasableNow(detail, id: id) && !result.basic.contains(id) {
                    result.basic.insert(id)
                }
            }
            
            // Trinkets: stable ids + tag-based fallback
            if [3340, 3363, 3364].contains(id) || tags.contains("Trinket") {
                if isPurchasableNow(detail, id: id) && !result.basic.contains(id) {
                    result.trinkets.insert(id)
                }
            }
            
            // Consumables: tag "Consumable" or "Potion" in plaintext/name (fallback)
            if tags.contains("Consumable")
                || detail.name.localizedCaseInsensitiveContains("Potion")
                || (detail.plaintext ?? "").localizedCaseInsensitiveContains("consume") {
                if isPurchasableNow(detail, id: id) && !result.basic.contains(id) {
                    result.consumables.insert(id)
                }
            }
            
            // Completed: cannot build further
            let isCompleted = (detail.into == nil || detail.into?.isEmpty == true)
            if isCompleted {
                if isPurchasableNow(detail, id: id) && !result.basic.contains(id) {
                    result.completed.insert(id)
                }
            }
            
            // Starters
            // depth == 1 and totla <= 500 and not trinket
            if (((detail.depth ?? 0) <= 1 &&
               detail.gold.total <= 500) ||
               detail.name.localizedCaseInsensitiveContains("World Atlas")),
               !result.trinkets.contains(id) {
                if isPurchasableNow(detail, id: id) && !result.basic.contains(id) {
                    result.starters.insert(id)
                }
            }
            
            // Mythic: riot remove mythic items. dummy data.
            let description = (detail.description ?? "")
            if description.localizedCaseInsensitiveContains(("Mythic Passive")) {
                if isPurchasableNow(detail, id: id) && !result.basic.contains(id) {
                    result.mythic.insert(id)
                }
            }
            
            // Legendary: completed, not boots/consumable/trinket, not mythic.
            if result.completed.contains(id),
               !result.boots.contains(id),
               !result.trinkets.contains(id),
               !result.consumables.contains(id),
               !result.mythic.contains(id),
               !result.advancedBoots.contains(id),
               (detail.gold.total >= 1500
                || detail.name.localizedCaseInsensitiveContains("Zaz'Zak's Realmspike")
                || detail.name.localizedCaseInsensitiveContains("Bloodsong")
                || detail.name.localizedCaseInsensitiveContains("Solstice Sleigh")
                || detail.name.localizedCaseInsensitiveContains("Dream Maker")
                || detail.name.localizedCaseInsensitiveContains("Celestial Opposition")
               ) {
                if isPurchasableNow(detail, id: id) && !result.basic.contains(id) {
                    result.legendary.insert(id)
                }
            }
            
            if !result.boots.contains(id),
               !result.trinkets.contains(id),
               !result.consumables.contains(id),
               !result.mythic.contains(id),
               !result.legendary.contains(id),
               !result.advancedBoots.contains(id),
               !result.starters.contains(id),
               !result.basic.contains(id),
               !result.epic.contains(id) {
                if isPurchasableNow(detail, id: id) || detail.name.localizedCaseInsensitiveContains("Runic Compass") {
                    result.epic.insert(id)
                }
            }

        }
        
        return result
    }

    static func isPurchasableNow(_ item: ItemDetail, id: Int, onMap mapId: String = "11") -> Bool {
        guard id <= 9999 else { return false }
        guard item.gold.purchasable else { return false }
        if let maps = item.maps, maps[mapId] != true { return false }
        //if item.inStore != nil { return false }
        return true
    }
}
