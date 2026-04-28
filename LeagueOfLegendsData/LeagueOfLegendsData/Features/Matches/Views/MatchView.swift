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
    @State private var matchIDcount: String = "1"
    
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
                .disabled(matchVM.isSaving || matchVM.isLoading)
                
                Button("Save") {
                    Task {
                        await matchVM.save(selectedServer, selectedTier)
                    }
                }
                .disabled(matchVM.isSaving || matchVM.isLoading)
                
                Button("Save All") {
                    Task {
                        await matchVM.saveAll(server: selectedServer)
                    }
                }
                .disabled(matchVM.isSaving || matchVM.isLoading)
                
            }
            .layoutPriority(1)
            .padding()
            .background(.ultraThinMaterial)
            
            
            if matchVM.isSaving && matchVM.saveAllTotal > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: matchVM.saveAllProgress)
                        .progressViewStyle(.linear)
                    
                    Text("\(matchVM.saveAllLabel) \(matchVM.saveAllCurrent)/\(matchVM.saveAllTotal)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            
            Divider()
            
            FlowLayout {
                VStack {
                    Text("Fetch match data and timeline")
                    TextField("Max 100", text: $matchIDcount)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button("Fetch and Save") {
                    Task {
                        await matchVM.getMatchTimelineDto(
                            server: selectedServer,
                            tier: selectedTier,
                            count: matchIDcount
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                
            }
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
            } else if matchVM.hasMatchIDs {
                List {
                    ForEach(Array(matchVM.matchIDs.enumerated()), id: \.element) { index, matchID in
                        Text("\(index + 1). Match ID: \(matchID)")
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
