//
//  APIError.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 2/12/26.
//
import Foundation

enum APIError: LocalizedError {
    case invalidURL(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL constructed: \(url)"
        }
    }
}
