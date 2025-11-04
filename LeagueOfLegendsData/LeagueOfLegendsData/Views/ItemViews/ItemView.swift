//
//  ItemView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/28/25.
//
import SwiftUI

struct ItemView: View {
    @EnvironmentObject var itemVM: ItemViewModel
    let version: String
    
    var body: some View {
        Group {
            if itemVM.isLoading {
                ProgressView("Loading items...")
            } else if let error = itemVM.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if let items = itemVM.itemModel {
                ItemListView(items: items, version: version)
            } else {
                Text("No data yet.")
            }
        }
        .task {
            await itemVM.load(version)
        }
    }
}
