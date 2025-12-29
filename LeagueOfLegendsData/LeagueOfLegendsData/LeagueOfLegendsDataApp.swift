//
//  LeagueOfLegendsDataApp.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/14/25.
//

import SwiftUI

@main
struct LeagueOfLegendsDataApp: App {
    init() {
        let cache = URLCache (
            memoryCapacity: 512 * 1024 * 1024,
            diskCapacity: 1024 * 1024 * 1024
        )
        URLCache.shared = cache
    }
    @StateObject private var versionVM = VersionViewModel(service: VersionService())
    @StateObject private var itemVM = ItemViewModel(service: ItemService())
    @StateObject private var championListVM = ChampionListViewModel(service: ChampionListService())
    @StateObject private var leagueVM = LeagueViewModel(service: LeagueService(), fileService: LeagueFileService())
    @StateObject private var fmVM = FileManagerViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(versionVM)
                .environmentObject(itemVM)
                .environmentObject(championListVM)
                .environmentObject(leagueVM)
                .environmentObject(fmVM)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Divider()
                Button("Open LeagueData Folder") {
                    fmVM.openFolder()
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }
    }
}
