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
    
    // Extract PUUIDs with map for each tier's file format
    func getPuuids(from file: URL, format: TierSelection) throws -> [String] {
        switch format {
        case .high:
            return try decodeUpperTier(from: file).entries.map(\.puuid)
        case .low:
            return try decodeLowerTier(from: file).map(\.puuid)
        }
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
    func saveHighTier (
        _ list: LeagueListDTO,
        _ server: Server,
        _ tier: HighTier,
        _ queue: RankQueue
    ) throws {
        let fileName = "\(tier.rawValue).json"
        
        let dir = leagueDataDirectory()
            .appending(path: "LeagueEntries", directoryHint: .isDirectory)
            .appending(path: server.rawValue, directoryHint: .isDirectory)
            .appending(path: queue.rawValue, directoryHint: .isDirectory)
            .appending(path: tier.display, directoryHint: .isDirectory)
        
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        } catch {
            throw FileSaveError.directoryCreationFailed
        }
        
        let url = dir.appending(component: fileName)
        
        let data: Data
        do {
            data = try JSONEncoder().encode(list.entries)
        } catch {
            throw FileSaveError.encodingFailed
        }
        
        do {
            try data.write(to: url)
        } catch {
            throw FileSaveError.writeFailed(url)
        }
    }
    
    // MARK: - Save lower tiers (Iron -> Diamond)
    func saveLowTier (
        _ entries: LeagueEntriesDTO,
        _ server: Server,
        _ division: Division,
        _ tier: LowTier,
        _ queue: RankQueue,
        _ page: Int
    ) throws {
        let fileName = "\(page).json"
        
        let dir = leagueDataDirectory()
            .appending(path: "LeagueEntries", directoryHint: .isDirectory)
            .appending(path: server.rawValue, directoryHint: .isDirectory)
            .appending(path: queue.rawValue, directoryHint: .isDirectory)
            .appending(path: tier.display, directoryHint: .isDirectory)
            .appending(path: division.rawValue, directoryHint: .isDirectory)
        
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        } catch {
            throw FileSaveError.directoryCreationFailed
        }
        
        let url = dir.appending(path: fileName)
        
        let data: Data
        do {
            data = try JSONEncoder().encode(entries)
        } catch {
            throw FileSaveError.encodingFailed
        }
        
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw FileSaveError.writeFailed(url)
        }
    }
}

