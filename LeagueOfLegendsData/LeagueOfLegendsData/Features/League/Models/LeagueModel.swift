//
//  LeagueModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/5/25.
//
//struct League {
//    let challenger = "challengerleagues"
//    let grandMaster = "grandmasterleagues"
//    let master = "masterleagues"
//}
//
//struct RankQueue {
//    let solo = "RANKED_SOLO_5x5"
//    let flexSR = "RANKED_FLEX_SR"
//    let flexTT = "RANKED_FLEX_TT"
//}
//
//struct Server {
//    let BR1 = "BR1"
//    let EUW1 = "EUW1"
//    let JP1 = "JP1"
//    let KR = "KR"
//    let LA1 = "LA1"
//    let LA2 = "LA2"
//    let ME1 = "ME1"
//    let NA1 = "NA1"
//    let OC1 = "OC1"
//    let RU = "RU"
//    let SG2 = "SG2"
//    let TR1 = "TR1"
//    let TW2 = "TW2"
//    let VN2 = "VN2"
//}
//
//struct Division {
//    let one = "I"
//    let two = "II"
//    let three = "III"
//    let four = "IV"
//}
//
//struct Tier {
//    let diamond = "DIAMOND"
//    let emerald = "EMERALD"
//    let platinum = "PLATINUM"
//    let gold = "GOLD"
//    let silver = "SILVER"
//    let bronze = "BRONZE"
//    let iron = "IRON"
//}

enum LeagueType: String, CaseIterable, Identifiable {
    case challenger = "challengerleagues"
    case grandMaster = "grandmasterleagues"
    case master = "masterleagues"
    
    var id: String { rawValue }
    var display: String {
        switch self{
        case .challenger: return "Challenger"
        case .grandMaster: return "GrandMaster"
        case .master: return "Master"
        }
    }
}

enum RankQueue: String, CaseIterable, Identifiable {
    case solo = "RANKED_SOLO_5x5"
    case flexSR = "RANKED_FLEX_SR"
    
    var id: String { rawValue }
    var display: String {
        switch self {
        case .solo: return "Solo Queue"
        case .flexSR: return "Flex SR"
        }
    }
}

enum Server: String, CaseIterable, Identifiable {
    case BR1 = "br1"
    case EUN1 = "eun1"
    case EUW1 = "euw1"
    case JP1 = "jp1"
    case KR = "kr"
    case LA1 = "la1"
    case LA2 = "la2"
    case ME1 = "me1"
    case NA1 = "na1"
    case OC1 = "oc1"
    case RU = "ru"
    case SG2 = "sg2"
    case TR1 = "tr1"
    case TW2 = "tw2"
    case VN2 = "vn2"
    
    var id: String { rawValue }
}

enum Tier: String, CaseIterable, Identifiable {
    case challenger = "challengerleagues"
    case grandMaster = "grandmasterleagues"
    case master = "masterleagues"
    case diamond = "DIAMOND"
    case emerald = "EMERALD"
    case platinum = "PLATINUM"
    case gold = "GOLD"
    case silver = "SILVER"
    case bronze = "BRONZE"
    case iron = "IRON"
    
    var id: String { rawValue }
    var display: String {
        switch self{
        case .challenger: return "Challenger"
        case .grandMaster: return "GrandMaster"
        case .master: return "Master"
        case .diamond: return "Diamond"
        case .emerald: return "Emerald"
        case .platinum: return "Platinum"
        case .gold: return "Gold"
        case .silver: return "Silver"
        case .bronze: return "Bronze"
        case .iron: return "Iron"
        }
    }
}

enum HighTier: String, CaseIterable, Identifiable {
    case challenger = "challengerleagues"
    case grandMaster = "grandmasterleagues"
    case master = "masterleagues"
    
    var id: String { rawValue }
    var display: String {
        switch self{
        case .challenger: return "Challenger"
        case .grandMaster: return "GrandMaster"
        case .master: return "Master"
        }
    }
}

enum LowTier: String, CaseIterable, Identifiable {
    case diamond = "DIAMOND"
    case emerald = "EMERALD"
    case platinum = "PLATINUM"
    case gold = "GOLD"
    case silver = "SILVER"
    case bronze = "BRONZE"
    case iron = "IRON"
    
    var id: String { rawValue }
    var display: String {
        switch self{
        case .diamond: return "Diamond"
        case .emerald: return "Emerald"
        case .platinum: return "Platinum"
        case .gold: return "Gold"
        case .silver: return "Silver"
        case .bronze: return "Bronze"
        case .iron: return "Iron"
        }
    }
}

enum Division: String, CaseIterable, Identifiable {
    case one = "I"
    case two = "II"
    case three = "III"
    case four = "IV"
    
    var id: String { rawValue }
}


// Master, Grand master, Challenger
struct LeagueListDTO: Codable {
    var tier: String
    var leagueId: String?
    var queue: String?
    var name: String?
    var entries: [LeagueItemDTO]
}

struct LeagueItemDTO: Codable {
    var puuid: String
    var leaguePoints: Int
    var rank: String
    var wins: Int
    var losses: Int
    var veteran: Bool
    var freshBlood: Bool
    var hotStreak: Bool
}

// Iron - Diamond
typealias LeagueEntriesDTO = [LeagueEntryDTO]

struct LeagueEntryDTO: Codable {
    var leagueId: String
    var queueType: String
    var tier: String
    var rank: String
    var puuid: String
    var leaguePoints: Int
    var wins: Int
    var losses: Int
    var veteran: Bool
    var inactive: Bool
    var freshBlood: Bool
    var hotStreak: Bool
}

// Low tier dictionary
typealias LowTierDictionary = [String:[String:[String:[String:[String:[LeagueEntriesDTO]]]]]]

// High tier dictionary
typealias HighTierDictionary = [String:[String:[LeagueListDTO]]]
