//
//  ChampionAnalyzed.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 5/2/26.
//

struct ChampionAnalyzed: Codable {
    var champions: [String: ChampionData]
}

struct ChampionData: Codable {
    var winRate: Int
    
    var strongAgainst: [MatchupStat]
    var weakAgainst: [MatchupStat]
    
    var summonerSpells: [SummonerSpellSet]
    var runes: [RuneSet]
    var items: [ItemBuildStat]
}

struct MatchupStat: Codable {
    let championName: String
    let winRate: Double
}

struct SummonerSpellSet: Codable {
    var spell1: Int
    var spell2: Int
    var frequency: Int
}

struct RuneSet: Codable {
    var primary: PrimaryRunePage
    var secondary: SecondaryRunePage
    var frequency: Int
}

struct PrimaryRunePage: Codable {
    var style: Int
    var perk1: Int
    var perk2: Int
    var perk3: Int
    var perk4: Int
}

struct SecondaryRunePage: Codable {
    var style: Int
    var perk1: Int
    var perk2: Int
}

struct ItemBuildStat: Codable {
    var items: [Int]
    var frequency: Int
}
