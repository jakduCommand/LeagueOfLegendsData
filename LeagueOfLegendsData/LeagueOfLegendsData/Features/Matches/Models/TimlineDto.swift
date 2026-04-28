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
    var levelUpType: String?
    var skillSlot: Int?
    var itemId: Int?
    var realTimestamp: Int?
    var type: String
}

typealias ParticipantFramesDto = [String: ParticipantFrameDto]

struct ParticipantFrameDto: Codable {
    
}
