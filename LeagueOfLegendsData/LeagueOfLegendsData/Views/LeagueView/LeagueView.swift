//
//  LeagueView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/16/25.
//
import SwiftUI

struct LeagueView: View {
    @EnvironmentObject var leagueVM: LeagueViewModel
    
    @State private var selectedLeague: LeagueType = .challenger
    @State private var selectedQueue: RankQueue = .solo
    @State private var selectedServer: Server = .NA1
    @State private var selectedTier: Tier = .challenger
    @State private var selectedDivision: Division = .one
    @State private var leagueListDTO: LeagueListDTO?
    @State private var leagueEntriesDTO: LeagueEntriesDTO?
    @State private var pageText: String = "1"
    
    var page: Int { Int(pageText) ?? 1}
    
    var isTopTier: Bool {
        selectedTier == .challenger ||
        selectedTier == .grandMaster ||
        selectedTier == .master
    }
    
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
                    Picker("tier", selection: $selectedTier) {
                        ForEach(Tier.allCases) { tier in
                            Text(tier.display).tag(tier)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if !isTopTier {
                    VStack(alignment: .leading, spacing: 4) {
                        Picker("Division", selection: $selectedDivision) {
                            ForEach(Division.allCases) { division in
                                Text(division.rawValue).tag(division)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                if !isTopTier {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Page", text: $pageText)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }
                
                
                Button("Fetch") {
                    Task {
                        leagueListDTO = nil
                        leagueEntriesDTO = nil
                        
                        if isTopTier {
                            leagueListDTO = try await leagueVM.getLeagueList(
                                selectedServer.rawValue,
                                selectedLeague.rawValue,
                                selectedQueue.rawValue
                            )
                        } else {
                            leagueEntriesDTO = try await leagueVM.getLeagueEntries (
                                selectedServer.rawValue,
                                selectedDivision.rawValue,
                                selectedTier.rawValue,
                                selectedQueue.rawValue,
                                page
                            )
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Save") {
                    Task {
                        if isTopTier {
                            guard let leagueListDTO else { return }
                            // TODO: save high tier(master - challenger)
                        } else {
                            guard let leagueEntriesDTO else { return }
                            // TODO: save low tier(iron - diamond)
                        }
                    }
                }
                
                Button("Save All Pages") {
                    Task {
                        // TODO: Save all pages.
                    }
                }
                .disabled(isTopTier)
            }
            .frame(minHeight: 70)
            .layoutPriority(1)
            .padding()
            .background(.ultraThinMaterial)
                    
            Divider()
            
            Spacer()
            // MARK: Display Results
            Group {
                if let dto = leagueListDTO {
                    List {
                        Section("\(dto.tier) - \(dto.name)") {
                            Text("Server: \(selectedServer.rawValue) | Queue: \(dto.queue) | ID: \(dto.leagueId)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            
                            ForEach(dto.entries, id: \.puuid) { entry in
                                LeagueRow(entry: entry)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                else if let dto = leagueEntriesDTO {
                    List {
                        Section("\(selectedTier.display) - Page \(page)") {
                            ForEach(dto, id: \.puuid) { entry in
                                
                                Text("Server: \(selectedServer.rawValue) | Queue: \(entry.queueType) | ID: \(entry.leagueId)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                LeagueRowEntries(entry: entry)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                else if let errorMessage = leagueVM.errorMessage {
                    Text("Error: \(errorMessage)")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(.systemRed))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if leagueVM.isLoading {
                    ProgressView()
                }
                else {
                    Text("Fetch League data to begin")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            Spacer()
            
        }
    }
}
