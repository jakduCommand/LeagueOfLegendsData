//
//  LeagueFileService.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 12/18/25.
//

import Foundation

var baseDirectory: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        .appending(path: "LeagueData", directoryHint: .isDirectory)
}

actor LeagueFileService {
    
    // Check files recursivley and return all json URL in the directory
    func allJSONFiles(in dir: URL) throws -> [URL] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: dir,
            includingPropertiesForKeys: [.isRegularFileKey]
        ) else {
            return []
        }
        
        var results: [URL] = []
        
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "json" {
                results.append(fileURL)
            }
        }
        
        return results
    }
    
    // For Master+ tier. Decodes entries
    func decodeUpperTier(from file: URL) throws -> LeagueListDTO {
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode(LeagueListDTO.self, from: data)
    }
    
    // For Iron - Diamond tier. Decodes entries
    func decodeLowerTier(from file: URL) throws -> LeagueEntriesDTO {
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode(LeagueEntriesDTO.self, from: data)
    }
    
    private func leagueDataDirectory() -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = base.appendingPathComponent("LeagueData", isDirectory: true)
        
        // Make sure if folder exists
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    
    // MARK: - Save top-tier (Master -> Challenger)
    func saveTopTierEntries (
        _ entries: LeagueListDTO,
        _ server: String,
        _ tier: String,
        _ queue: String
    ) {
        let fileName = "\(tier).json"
        
        let dir = leagueDataDirectory()
            .appending(path: "LeagueEntries", directoryHint: .isDirectory)
            .appending(path: server, directoryHint: .isDirectory)
            .appending(path: queue, directoryHint: .isDirectory)

        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        
        let url = dir.appending(path: fileName)
        
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: url, options: .atomic)
            print("Saved top-tier entries to: \(url.path)")
        } catch {
            print("Failed to save top-tier entries:", error)
        }
    }
    
    // MARK: - Save lower tiers (Iron -> Diamond)
    func saveEntries(
        _ entries: LeagueEntriesDTO,
        _ server: String,
        _ division: String,
        _ tier: String,
        _ queue: String,
        _ page: String
    ) {
        let fileName = "\(page).json"
        
        let dir = leagueDataDirectory()
            .appending(path: "LeagueEntries", directoryHint: .isDirectory)
            .appending(path: server, directoryHint: .isDirectory)
            .appending(path: queue, directoryHint: .isDirectory)
            .appending(path: tier, directoryHint: .isDirectory)
            .appending(path: division, directoryHint: .isDirectory)
        
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        
        let url = dir.appending(path: fileName)
        
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: url, options: .atomic)
            print("Saved entries to: \(url.path)")
        } catch {
            print("Failed to save entries:", error)
        }
    }
}

