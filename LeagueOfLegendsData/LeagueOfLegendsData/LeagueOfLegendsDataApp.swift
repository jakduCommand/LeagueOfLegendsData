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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(versionVM)
                .environmentObject(itemVM)
        }
    }
}
