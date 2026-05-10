//
//  ChampionMatchSample.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 4/30/26.
//

struct ChampionMatchSample: Codable {
    var matchId: String
    var gameVersion: String
    var queueId: Int
    var gameDuration: Int
    
    var participantId: Int
    var teamId: Int
    
    var championId: Int
    var championName: String
    var position: String
    var opponentChampionId: Int?
    
    var win: Bool
    
    var summonerSpellIds: [Int]
    var runeIds: [Int]
    var statRuneIds: [Int]
    
    var starterItemIds: [Int]
    var coreItemSequence: [Int]
    var bootItemId: Int?
    
    var powerCurve: [PowerCurvePoint]
}

struct PowerCurvePoint: Codable {
    var minute: Int
    var level: Int
    var totalGold: Int
    var xp: Int
    var cs: Int
    var damageToChampions: Int
}
