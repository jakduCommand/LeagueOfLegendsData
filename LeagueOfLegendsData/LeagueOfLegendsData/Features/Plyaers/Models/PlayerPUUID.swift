//
//  PlayerPUUID.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 12/18/25.
//

struct PlayerPUUID: Hashable, Codable {
    let puuid: String
    let server: String
    let queue: String
    let tier: String
    let division: String
}
