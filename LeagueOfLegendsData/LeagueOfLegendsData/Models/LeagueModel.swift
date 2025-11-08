//
//  LeagueModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/5/25.
//

// Master, Grand master, Challenger
struct LeagueListDTO: Decodable {
    var tier: String
    var leagueId: String
    var queue: String
    var name: String
    var entries: [LeagueItemDTO]
}

struct LeagueItemDTO: Decodable {
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
struct LeagueEntriesDTO: Decodable {
    var leagueEntries: [LeagueEntryDTO]
}

struct LeagueEntryDTO: Decodable {
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
