//
//  MatchError.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 4/21/26.
//
import Foundation

enum MatchError: LocalizedError {
    case noMatchIDs
    
    var errorDescription: String? {
        switch self {
        case .noMatchIDs:
            return "There is no such matchID"
        }
    }
}
