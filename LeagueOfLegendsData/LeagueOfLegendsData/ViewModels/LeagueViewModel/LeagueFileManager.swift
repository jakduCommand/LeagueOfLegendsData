//
//  LeagueFileManager.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/24/25.
//

import Foundation

extension LeagueViewModel {
    
    private func leagueDataDirectory() -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = base.appendingPathComponent("LeagueData", isDirectory: true)
        
        // Make sure if folder exists
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    
    private func makeFileURL(server: String, queue: String, tier: String, division: String? = nil) -> URL {
        var path = leagueDataDirectory()
            .appendingPathComponent(server)
            .appendingPathComponent(queue)
            .appendingPathComponent(tier)
        
        if let division = division {
            path = path.appendingPathComponent("\(division).json")
        } else {
            path = path.appendingPathExtension("json")
        }
        
        try? FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
        return path
    }
    
    // MARK: - save top-tier (Master -> Challenger)
    func saveTopTierEntires (
        _ server: String,
        _ tier: String,
        _ queue: String
    ) {
        guard let dto = leagueListDTO else { return }
        let url = makeFileURL(server: server, queue: queue, tier: tier)
        
        do {
            let data = try JSONEncoder().encode(dto)
            try data.write(to: url, options: .atomic)
            print("Saved top-tier entries to: \(url.path)")
        } catch {
            print("Failed to save top-tier entries:", error)
        }
    }
    
    // MARK: - Save lower tiers (Iron -> Diamond)
    func saveEntries(
        _ server: String,
        _ division: String,
        _ tier: String,
        _ queue: String
    ) {
        guard let dto = leagueEntriesDTO else { return }
        let fileName = "\(tier)-\(division).json"
        
        let dir = leagueDataDirectory()
            .appendingPathComponent(server)
            .appendingPathComponent(queue)
            .appendingPathComponent(tier)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        
        let url = dir.appendingPathComponent(fileName)
        
        do {
            let data = try JSONEncoder().encode(dto)
            try data.write(to: url, options: .atomic)
            print("Saved entries to: \(url.path)")
        } catch {
            print("Failed to save entries:", error)
        }
    }
    
}
