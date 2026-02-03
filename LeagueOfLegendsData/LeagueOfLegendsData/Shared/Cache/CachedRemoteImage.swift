//
//  CachedRemoteImage.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/29/25.
//
import SwiftUI
import Combine
import AppKit

struct CachedRemoteImage: View {
    @StateObject private var loader = ImageLoader()
    let url: URL
    let size: CGFloat
    
    var body: some View {
        Group {
            if let nsImage = loader.image {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .frame(width: size, height: size)
            }
        }
        .frame(width: size, height: size)
        .task {
            await loader.load(from: url)
        }
    }
}
