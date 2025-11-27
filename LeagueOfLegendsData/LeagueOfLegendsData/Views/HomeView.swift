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
                Text("Settings")
                    .tag("Settings")
                Text("Files")
                    .tag("Files")
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
            case "Settings":
                APIKeyView()
            case "Files":
                FileManagerView()
            default:
                ItemView(version: version)
            }
        }
        .onAppear {
            ImageCache.shared.clear()
        }
    }
}
