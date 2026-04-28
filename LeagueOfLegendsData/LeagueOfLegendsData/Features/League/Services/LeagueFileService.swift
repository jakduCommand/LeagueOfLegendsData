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
    // MARK: - Directory
    private func leagueDataDirectory() -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = base.appendingPathComponent("LeagueData", isDirectory: true)
        
        // Make sure if folder exists
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    
    func getDirectory(
        server: Server,
        tier: TierSelection
    ) -> URL {
        return leagueDataDirectory()
            .appending(path: "LeagueEntries", directoryHint: .isDirectory)
            .appending(path: server.rawValue, directoryHint: .isDirectory)
            .appending(path: RankQueue.solo.rawValue, directoryHint: .isDirectory)
            .appending(path: tier.display, directoryHint: .isDirectory)
 
    }
    
    // MARK: - Read
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
    
    // MARK: - Decode
    // For Master+ tier. Decodes entries
    func decodeUpperTier(from file: URL) throws -> [LeagueItemDTO] {
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode([LeagueItemDTO].self, from: data)
    }
    
    // For Iron - Diamond tier. Decodes entries
    func decodeLowerTier(from file: URL) throws -> LeagueEntriesDTO {
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode(LeagueEntriesDTO.self, from: data)
    }
    
    func decodeMatchId(from file: URL) throws -> [String] {
        let data = try Data(contentsOf: file)
        
        return try JSONDecoder().decode([String].self, from: data)
    }
    
    // MARK: - Extract
    // Extract PUUIDs with map for each tier's file format
    func getPuuids(from file: URL, format: TierSelection) throws -> [String] {
        switch format {
        case .high(_):
            return try decodeUpperTier(from: file).map(\.puuid)
        case .low(_):
            return try decodeLowerTier(from: file).map(\.puuid)
        }
    }
    
    // Recursively extract PUUIDs under a root file and skip bad files
    func getPuuidsRecursively (
        from root: URL,
        format: TierSelection
    ) throws -> [String] {
        
        let fm = FileManager.default
        var all: [String] = []
        
        // If it's already a file, just attempt decode and return
        if !root.hasDirectoryPath {
            return (try? getPuuids(from: root, format: format)) ?? []
        }
        
        guard let enumerator = fm.enumerator (
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        for case let url as URL in enumerator {
            // Only .json files
            guard url.pathExtension.lowercased() == "json" else { continue }
            
            // Make sure it's a regular file
            guard let values = try? url.resourceValues(forKeys: [.isRegularFileKey]),
                  values.isRegularFile == true else { continue }
            
            // Try decode - skip if it fails
            if let puuids = try? getPuuids(from: url, format: format) {
                all.append(contentsOf: puuids)
            }
        }
        
        return all
    }
    
    func getMatchIDs(server: Server, tier: TierSelection) throws -> [String] {
        let fileName = "matchIDs.json"
        
        let dir = leagueDataDirectory()
            .appending(path: "Matches", directoryHint: .isDirectory)
            .appending(path: server.rawValue, directoryHint: .isDirectory)
            .appending(path: tier.display, directoryHint: .isDirectory)
        
        let url = dir.appending(path: fileName)
        
        return try decodeMatchId(from: url)
    }
    
    // MARK: - Save League Entries
    // Save top tiers
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
    
    // Save lower tier
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
    
    // MARK: - Save Match IDs
    func saveMatchID (
        _ matchIDs: [String],
        _ server: Server,
        _ tier: TierSelection
    ) throws {
        let fileName = "matchIDs.json"
        
        let dir = leagueDataDirectory()
            .appending(path: "Matches", directoryHint: .isDirectory)
            .appending(path: server.rawValue, directoryHint: .isDirectory)
            .appending(path: tier.display, directoryHint: .isDirectory)
        
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        
        let url = dir.appending(path: fileName)
        
        do {
            let data = try JSONEncoder().encode(matchIDs)
            try data.write(to: url, options: .atomic)
            print("Saved match IDs to: \(url.path)")
        } catch {
            print("Failed to save match IDs:", error)
            throw error
        }
    }
    
    // MARK: - Save MatchDto and Timeline
    func saveMatchDtoTimeline (
        _ matchDto: MatchDto,
        _ timelineDto: TimelineDto,
        _ server: Server,
        _ tier: TierSelection
    ) throws {
        let matchID = matchDto.metadata.matchId
        let matchDtoFileName = "matchDto_\(matchID).json"
        let timelineFileName = "timelineDto_\(matchID).json"
        
        let matchDtoDir = leagueDataDirectory()
            .appending(path: "MatchDto", directoryHint: .isDirectory)
            .appending(path: server.rawValue, directoryHint: .isDirectory)
            .appending(path: tier.display, directoryHint: .isDirectory)
        
        let timelineDtoDir = leagueDataDirectory()
            .appending(path: "TimelineDto", directoryHint: .isDirectory)
            .appending(path: server.rawValue, directoryHint: .isDirectory)
            .appending(path: tier.display, directoryHint: .isDirectory)
        
        try FileManager.default.createDirectory(at: matchDtoDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: timelineDtoDir, withIntermediateDirectories: true)
        
        let matchDtoURL = matchDtoDir.appending(path: matchDtoFileName)
        let timelineDtoURL = timelineDtoDir.appending(path: timelineFileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let matchDtoData = try encoder.encode(matchDto)
            let timelineDtoData = try encoder.encode(timelineDto)
            
            try matchDtoData.write(to: matchDtoURL, options: .atomic)
            try timelineDtoData.write(to: timelineDtoURL, options: .atomic)
        } catch {
            throw error
        }
    }
}

