//
//  LeagueRowEntries.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/18/25.
//

//struct LeagueEntryDTO: Decodable {
//    var leagueId: String
//    var queueType: String
//    var tier: String
//    var rank: String
//    var puuid: String
//    var leaguePoints: Int
//    var wins: Int
//    var losses: Int
//    var veteran: Bool
//    var inactive: Bool
//    var freshBlood: Bool
//    var hotStreak: Bool
//    
//}
import SwiftUI

struct LeagueRowEntries: View {
    let entry: LeagueEntryDTO
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            Text("PUUID: \(entry.puuid)")
                .font(.caption)
            
            HStack {
                Text("LP: \(entry.leaguePoints)")
                Text("Rank: \(entry.rank)")
                Text("W \(entry.wins) / L \(entry.losses)")
            }
            .font(.subheadline)
            
            
            HStack {
               if entry.hotStreak { Label("Hot", systemImage: "flame.fill") }
               if entry.freshBlood { Label("Fresh", systemImage: "star.fill") }
               if entry.veteran { Label("Veteran", systemImage: "shield.fill") }
           }
           .font(.caption)
           .foregroundColor(.orange)
        }
        .padding(.vertical, 4)
    }
}
