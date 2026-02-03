//
//  ImageCache.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/29/25.
//
import AppKit
import SwiftUI
import Combine

final class ImageCache {
    static let shared = ImageCache()
    private init() {}
    
    private var cache = NSCache<NSURL, NSImage>()
    
    func image(for url: URL) -> NSImage? {
        cache.object(forKey: url as NSURL)
    }
    
    func insert(_ image: NSImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func clear() {
        cache.removeAllObjects()
        print("ImageCache cleared.")
    }
}





