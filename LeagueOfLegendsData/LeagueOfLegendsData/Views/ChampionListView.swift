//
//  ChampionListView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/4/25.
//
import SwiftUI

struct ChampionListView: View {
    @EnvironmentObject var championListVM: ChampionListViewModel
    let version: String
    
    private let columns = [GridItem(.adaptive(minimum: 60))]
    
    var body: some View {
        Group {
            if championListVM.isLoading {
                ProgressView("Loading Champion list...")
            } else if let error = championListVM.errorMessage {
                Text("Error: \(error)").foregroundColor(.red)
            } else {
                let ids = championListVM.getChampionList()
                if ids.isEmpty {
                    Text("No champions found.")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(ids, id: \.self) { id in
                                if let champ = championListVM.championList?.data[id] {
                                    VStack {
                                        if let url = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/champion/\(champ.id).png") {
                                            CachedRemoteImage(url: url, size: 60)
                                        } else {
                                            Color.gray.frame(width: 60, height: 60)
                                        }
                                        Text(champ.name)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .task {
            if championListVM.championList == nil {
                await championListVM.load(version)
            }
        }
        .navigationTitle("Champions")
    }
}
