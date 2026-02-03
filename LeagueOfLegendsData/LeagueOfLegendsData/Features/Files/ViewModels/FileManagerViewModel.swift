//
//  FileManagerViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/25/25.
//
import Foundation
import Combine
import SwiftUI

@MainActor
final class FileManagerViewModel: ObservableObject {
    @Published var files: [SavedFile] = []
    @Published var errorMessage: String?
    
    struct SavedFile: Identifiable {
        let id = UUID()
        let url: URL
        var name: String { url.lastPathComponent }
        var size: Int64
        var modified: Date
    }
    
    init() {
        loadFiles()
    }
    
    func getBaseDirectory() -> URL {
        return baseDirectory
    }
    
    func loadFiles() {
        var collected: [SavedFile] = []
        
        guard FileManager.default.fileExists(atPath: baseDirectory.path) else {
            files = []
            return
        }
        
        let fm = FileManager.default
        let enumerator = fm.enumerator(at: baseDirectory, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey])
        
        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "json" else { continue }
            
            do {
                let attrs = try fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                let size = Int64(attrs.fileSize ?? 0)
                let date = attrs.contentModificationDate ?? Date.distantPast
                collected.append(SavedFile(url: fileURL, size: size, modified: date))
            } catch {
                errorMessage = "Failed to read file attributes for \(fileURL.lastPathComponent)"
            }
        }
        
        files = collected.sorted(by: { $0.modified > $1.modified })
    }
    
    func deleteFile(_ file: SavedFile) {
        do {
            try FileManager.default.removeItem(at: file.url)
            loadFiles()
        } catch {
            errorMessage = "Failed to delete file: \(error.localizedDescription)"
        }
    }
    
    func clearAll() {
        do {
            if FileManager.default.fileExists(atPath: baseDirectory.path) {
                try FileManager.default.removeItem(at: baseDirectory)
            }
            loadFiles()
        } catch {
            errorMessage = "Failed to clear files: \(error.localizedDescription)"
        }
    }
    
    func openFile(_ file: SavedFile) {
        NSWorkspace.shared.open(file.url)
    }
    
    func openFolder() {
        if !FileManager.default.fileExists(atPath: baseDirectory.path) {
            try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        }
        NSWorkspace.shared.open(baseDirectory)
    }
}
