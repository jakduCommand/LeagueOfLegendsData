//
//  FileSaveError.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 1/1/26.
//
import Foundation

enum FileSaveError: LocalizedError {
    case encodingFailed
    case directoryCreationFailed
    case writeFailed(URL)
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode league entries."
        case .directoryCreationFailed:
            return "Failed to create save directory."
        case .writeFailed(let url):
            return "Failed to write file to \(url.lastPathComponent)."
        }
    }
}
