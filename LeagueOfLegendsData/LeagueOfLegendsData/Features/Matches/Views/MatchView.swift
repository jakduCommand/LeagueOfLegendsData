//
//  MatchView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 2/13/26.
//
import SwiftUI

struct MatchView: View {
    @EnvironmentObject var matchVM: MatchViewModel
    
    @State private var selectedLeague: LeagueType = .challenger
    @State private var selectedServer: Server = .NA1
    @State private var selectedTier: TierSelection = .high(.challenger)
    
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
                    Picker("Tier", selection: $selectedTier) {
                        ForEach(TierSelection.allCases) { tier in
                            Text(tier.display).tag(tier)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Button("Fetch") {
                    Task {                        
                        await matchVM.getMatchIds(server: selectedServer, tier: selectedTier)
                    }
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
            if let errorMessage = matchVM.errorMessage {
                VStack {
                    Text("Error: \(errorMessage)")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(.systemRed))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .textSelection(.enabled)
                }
            } else if let matchIDs = matchVM.matchIDs {
                List {
                    ForEach(matchIDs, id: \.self) { matchID in
                        Text("Match ID: \(matchID)")
                            .textSelection(.enabled)
                    }
                }
            } else {
                VStack {
                    Text("Fetch match data to begin")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            Spacer()
        }
    }
}
