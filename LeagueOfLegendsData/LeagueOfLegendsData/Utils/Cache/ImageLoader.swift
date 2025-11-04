//
//  ImageLoader.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/29/25.
//
import SwiftUI
import Combine
import AppKit

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: NSImage?
    
    func load(from url: URL) async {
        if let cached = ImageCache.shared.image(for: url) {
            self.image = cached
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200,
                  let img = NSImage(data: data)
            else {return}
            
            ImageCache.shared.insert(img, for: url)
            self.image = img
        } catch {
            print("Image load failed: \(error)")
        }
    }
}
