//
//  TierSelection.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 1/2/26.
//

import Foundation

enum TierSelection: Identifiable, CaseIterable, Hashable {
    case high(HighTier)
    case low(LowTier)
    
    static var allCases: [TierSelection] {
        HighTier.allCases.map { .high($0) } +
        LowTier.allCases.map { .low($0) }
    }
    
    var id: String {
            switch self {
            case .high(let t): return t.rawValue
            case .low(let t): return t.rawValue
            }
        }

        var display: String {
            switch self {
            case .high(let t): return t.display
            case .low(let t): return t.display
            }
        }
}
