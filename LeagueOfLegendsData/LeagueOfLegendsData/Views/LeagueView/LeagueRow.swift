//
//  LeagueRow.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/17/25.
//
import SwiftUI

struct LeagueRow: View {
    let entry: LeagueItemDTO
    
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
