//
//  MatchModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/30/25.
//
struct MatchDto: Codable {
    var metadata: MetadataDto
    var info: InfoDto
}


struct MetadataDto: Codable {
    var dataVersion: String
    var matchId: String
    var participants: [String]
}

struct InfoDto: Codable {
    var endOfGameResult: String
    var gameDuration: Int
    var participants: [ParticipantDto]
}

struct ParticipantDto: Codable {
    var championId: Int
    var championName: String
    var individualPosition: String
    var item0: Int
    var item1: Int
    var item2: Int
    var item3: Int
    var item4: Int
    var item5: Int
    var item6: Int
    var perks: PerksDto
    var teamPosition: String
    var win: Bool
    var kills: Int
    var goldEarned: Int
    var goldSpent: Int
}

struct PerksDto: Codable {
    var statPerks: PerkStatsDto
    var styles: [PerkStyleDto]
}

struct PerkStatsDto: Codable {
    var defense: Int
    var flex: Int
    var offense: Int
}

struct PerkStyleDto: Codable {
    var description: String
    var selections: [PerkStyleSelectionDto]
    var style: Int
}

struct PerkStyleSelectionDto: Codable {
    var perk: Int
    var var1: Int
    var var2: Int
    var var3: Int
}
