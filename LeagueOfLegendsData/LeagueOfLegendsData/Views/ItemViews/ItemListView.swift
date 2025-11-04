//
//  ItemListView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/29/25.
//
import SwiftUI

struct ItemListView: View {
    let items: ItemModel
    @EnvironmentObject var itemVM: ItemViewModel
    let version: String
    private let columns = [GridItem(.adaptive(minimum: 60))]
    
    var body: some View {
        ScrollView {
            let categorizedItems = itemVM.getItems()
            
            VStack(alignment: .leading, spacing: 24) {
                ForEach(Array(categorizedItems.allCategories.keys), id: \.self) { category in
                    if let ids = categorizedItems.allCategories[category],
                       !ids.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(Array(ids).sorted(), id: \.self) { id in
                                    if let item = categorizedItems.items[id] {
                                        VStack {
                                            if let url = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/item/\(id).png") {
                                                CachedRemoteImage(url: url, size: 50)
                                            } else {
                                                Color.gray
                                                    .frame(width: 50, height: 50)
                                            }
                                            
                                            Text(item.name)
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                                .frame(height: 28)
                                        }
                                        .frame(width: 60, height: 90)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
