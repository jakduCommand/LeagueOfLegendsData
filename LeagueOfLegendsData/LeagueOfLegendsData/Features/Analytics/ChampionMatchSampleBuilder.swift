//
//  ChampionMatchSampleBuilder.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 4/30/26.
//

actor ChampionMatchSampleBuilder {
    private let itemService: ItemService
    private let leagueFileService: LeagueFileService
    
    
    init() {
        itemService = ItemService()
        leagueFileService = LeagueFileService()
    }
    
    func build (
        version: String,
        server: Server?,
        tier: TierSelection?,
        matchId: String?
    ) async throws -> [ChampionMatchSample] {
        
        let itemData = try await itemService.fetchItems(version)
        
        
        let itemAnalyzer = ItemAnalyzer(itemData.data)
        let runeExtractor = RuneExtractor()
        
        let matchData = try await leagueFileService.readMatchDtoTimelineDto(
            matchId,
            server,
            tier
        )
        
        var samples: [ChampionMatchSample] = []
        
        for (matchDto, timelineDto) in matchData {
            let participants = matchDto.info.participants
            let opponentMap = makeOpponentMap(participants)
            
            // extract all events for each participant
            let allEvents = timelineDto.info.frames.flatMap { $0.events }
            let eventsByParticipant = Dictionary(grouping: allEvents) {
                $0.participantId
            }
            
            let matchSamples = participants.map { participant in
                let events = eventsByParticipant[participant.participantId] ?? []
                
                let frames = framesForParticipant (
                    participantId: participant.participantId,
                    timelineDto: timelineDto
                )
                
                return ChampionMatchSample (
                    matchId: matchDto.metadata.matchId,
                    gameVersion: matchDto.info.gameVersion,
                    queueId: matchDto.info.queueId,
                    gameDuration: matchDto.info.gameDuration,
                    participantId: participant.participantId,
                    teamId: participant.teamId,
                    championId: participant.championId,
                    championName: participant.championName,
                    position: participant.teamPosition,
                    opponentChampionId: opponentMap[participant.participantId]?.championId,
                    win: participant.win,
                    summonerSpellIds: [
                        participant.summoner1Id,
                        participant.summoner2Id
                    ],
                    runeIds: runeExtractor.extractRune(participant),
                    statRuneIds: runeExtractor.extractStatRune(participant),
                    starterItemIds: itemAnalyzer.starterItems(from: events),
                    coreItemSequence: itemAnalyzer.coreItems(from: events),
                    bootItemId:
                        itemAnalyzer.boots(from: events),
                    powerCurve: buildPowerCurve(from: frames)
                )
            }
            samples.append(contentsOf: matchSamples)
        }
        
        return samples
    }
    
    // For strong/weak against, match same lane on enemy team.
    private func makeOpponentMap(
        _ participants: [ParticipantDto]
    ) -> [Int: ParticipantDto] {
        
        var result: [Int: ParticipantDto] = [:]
        
        for participant in participants {
            guard !participant.teamPosition.isEmpty else { continue }
            
            let opponent = participants.first {
                $0.teamId != participant.teamId &&
                $0.teamPosition == participant.teamPosition
            }
            
            if let opponent {
                result[participant.participantId] = opponent
            }
        }
        
        return result
    }
    
    // Extract timeline frames
    private func framesForParticipant (
        participantId: Int,
        timelineDto: TimelineDto
    ) -> [ParticipantFrameDto] {
        
        timelineDto.info.frames.compactMap { frame in
            frame.participantFrames[String(participantId)]
        }
    }
    
    // Power curve
    private func buildPowerCurve (
        from frames: [ParticipantFrameDto]
    ) -> [PowerCurvePoint] {
        
        frames.enumerated().map { index, frame in
            PowerCurvePoint (
                minute: index,
                level: frame.level,
                totalGold: frame.totalGold,
                xp: frame.xp,
                cs: frame.minionsKilled + frame.jungleMinionsKilled,
                damageToChampions: frame.damageStats.totalDamageDoneToChampions
            )
        }
    }
}
