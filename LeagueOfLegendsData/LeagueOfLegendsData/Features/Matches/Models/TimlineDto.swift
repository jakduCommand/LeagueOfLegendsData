//
//  TimlineDto.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 4/21/26.
//

struct TimelineDto: Codable {
    var metadata: MetadataTimeLineDto
    var info: InfoTimeLineDto
}

struct MetadataTimeLineDto: Codable {
    var dataVersion: String
    var matchId: String
}

struct InfoTimeLineDto: Codable {
    var endOfGameResult: String
    var frameInterval: Int
    var participants: [ParticipantTimeLineDto]
    var frames: [FramesTimeLineDto]
}

struct ParticipantTimeLineDto: Codable {
    var participantId: Int
    var puuid: String
}

struct FramesTimeLineDto: Codable {
    var events: [EventsTimeLineDto]
    var participantFrames: ParticipantFramesDto
    var timestamp: Int
}

struct EventsTimeLineDto: Codable {
    var timestamp: Int
    var participantId: Int?
    var type: String
    
    var itemId: Int?
    var afterId: Int?
    var beforeId: Int?
    
    var levelUpType: String?
    var skillSlot: Int?
    var realTimestamp: Int?
}

typealias ParticipantFramesDto = [String: ParticipantFrameDto]

struct ParticipantFrameDto: Codable {
    var participantId: Int
    var championStats: ChampionStatsDto
    var currentGold: Int
    var totalGold: Int
    var level: Int
    var xp: Int
    var minionsKilled: Int
    var jungleMinionsKilled: Int
    var damageStats: DamageStatsDto
    var position: PositionDto?
}

struct DamageStatsDto: Codable {
    var totalDamageDoneToChampions: Int
    var physicalDamageDoneToChampions: Int
    var magicDamageDoneToChampions: Int
    var trueDamageDoneToChampions: Int
}

struct ChampionStatsDto: Codable {
    var abilityHaste: Int
    var armor: Int
    var armorPen: Int
    var armorPenPercent: Int
    var attackDamage: Int
    var attackSpeed: Int
    var bonusArmorPenPercent: Int
    var bonusMagicPenPercent: Int
    var ccReduction: Int
    var cooldownReduction: Int
    var health: Int
    var healthMax: Int
    var healthRegen: Int
    var lifesteal: Int
    var magicPen: Int
    var magicPenPercent: Int
    var magicResist: Int
    var movementSpeed: Int
    var omnivamp: Int
    var physicalVamp: Int
    var power: Int
    var powerMax: Int
    var powerRegen: Int
    var spellVamp: Int
}

struct PositionDto: Codable {
    var x: Int
    var y: Int
}
