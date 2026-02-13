//
//  NavigationSplitView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/26/25.
//
import SwiftUI

struct HomeView: View {
    let version: String
    
    @State private var selection: String? = "Items"
    var body: some View {
        NavigationSplitView {
            // Sidebar list
            List(selection: $selection) {
                Text("Items")
                    .tag("Items")
                Text("Champions")
                    .tag("Champions")
                Text("Players")
                    .tag("Players")
                Text("Matches")
                    .tag("Matches")
                Text("Files")
                    .tag("Files")
                Text("Test")
                    .tag("Test")
                Text("Settings")
                    .tag("Settings")
            }
            .navigationTitle("Home")
        } detail: {
            switch selection {
            case "Items":
                ItemView(version: version)
            case "Champions":
                ChampionListView(version: version)
            case "Players":
                LeagueView()
            case "Matches":
                MatchView()
            case "Files":
                FileManagerView()
            case "Test":
                TestView()
            case "Settings":
                APIKeyView()
            default:
                ItemView(version: version)
            }
        }
        .onAppear {
            ImageCache.shared.clear()
        }
    }
}
