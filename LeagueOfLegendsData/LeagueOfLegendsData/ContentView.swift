//
//  ContentView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/14/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var versionVM: VersionViewModel
    @EnvironmentObject var itemVM: ItemViewModel
    var body: some View {
        Group {
            if let version = versionVM.currentVersion {
                HomeView(version: version)
            } else if versionVM.isLoading {
                ProgressView("Loading version...")
            } else if let error = versionVM.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
        }
        .task {
            if versionVM.currentVersion == nil {
                await versionVM.load()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(VersionViewModel(service: VersionService()))
        .environmentObject(ItemViewModel(service: ItemService()))
}
