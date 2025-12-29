//
//  NetworkError.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/29/25.
//
import Foundation

enum NetworkError: Error, LocalizedError {
    case badResponse(url: URL, statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .badResponse(let url, let code):
            return "Bad response (\(code)) for \(url)"
        }
    }
}
