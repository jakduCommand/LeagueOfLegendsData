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
    @State private var selectedTier: TierSelection = .high(.challenger)
    @State private var selectedDivision: Division = .one

    @State private var pageText: String = "1"
    
    var page: Int { Int(pageText) ?? 1}
    
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
                
                if case .low = selectedTier {
                    VStack(alignment: .leading, spacing: 4) {
                        Picker("Division", selection: $selectedDivision) {
                            ForEach(Division.allCases) { division in
                                Text(division.rawValue).tag(division)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                if case .low = selectedTier {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Page", text: $pageText)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }
                
                
                Button("Fetch") {
                    Task {
                        leagueVM.startFetch(
                            server: selectedServer,
                            queue: selectedQueue,
                            tier: selectedTier,
                            division: selectedDivision,
                            page: page
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Save") {
                    Task {
                        await leagueVM.save(
                            server: selectedServer,
                            queue: selectedQueue,
                            tier: selectedTier,
                            division: selectedDivision,
                            page: page)
                    }
                }
                
                Button("Save All") {
                    leagueVM.start(server: selectedServer)
                }
                .disabled(leagueVM.isSaving)
                
                if leagueVM.isSaving {
                    ProgressView(
                        value: Double(leagueVM.done),
                        total: Double(max(leagueVM.total, 1))
                    )
                    .frame(width: 140)
                    
                    Text("\(leagueVM.done)/\(leagueVM.total)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Button("Cancel") { leagueVM.cancel() }
                        .font(.footnote)
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
                if let dto = leagueVM.leagueListDTO {
                    List {
                        ForEach(dto.entries, id: \.puuid) { entry in
                            LeagueRow(entry: entry)
                        }
                    }
                    .listStyle(.plain)
                }
                else if let dto = leagueVM.leagueEntriesDTO {
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
                        .textSelection(.enabled)
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
