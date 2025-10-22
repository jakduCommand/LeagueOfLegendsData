//
//  LeagueOfLegendsDataApp.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/14/25.
//

import SwiftUI

@main
struct LeagueOfLegendsDataApp: App {
    @StateObject private var mainVM = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mainVM)
        }
    }
}
