//
//  MatchView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 2/13/26.
//
import SwiftUI

struct MatchView: View {
    
    @State private var selectedLeague: LeagueType = .challenger
    @State private var selectedQueue: RankQueue = .solo
    @State private var selectedServer: Server = .NA1
    @State private var selectedTier: TierSelection = .high(.challenger)
    @State private var selectedDivision: Division = .one
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Buttons
            FlowLayout {
                VStack(alignment: .leading, spacing: 4) {
                    Picker("Server", selection: $selectedServer) {
                        ForEach(Server.allCases) { server in
                            Text(server.rawValue).tag(server)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Picker("Queue", selection: $selectedQueue) {
                        ForEach(RankQueue.allCases) { queue in
                            Text(queue.display).tag(queue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Picker("Tier", selection: $selectedTier) {
                        ForEach(TierSelection.allCases) { tier in
                            Text(tier.display).tag(tier)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Button("Fetch") {
                }
                .buttonStyle(.borderedProminent)
                
                Button("Save") {
                }
                
                Button("Save All") {
                }
                
            }
            .frame(minHeight: 70)
            .layoutPriority(1)
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            Spacer()
            
            // MARK: Display Results
            VStack {
                Text("Fetch match data to begin")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
    }
}
