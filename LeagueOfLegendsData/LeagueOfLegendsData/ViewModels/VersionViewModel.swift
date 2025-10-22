//
//  VersionViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/21/25.
//
import SwiftUI
import Foundation
import Combine

protocol VersionServicing {
    func fetchVersions() async throws -> [String]
}

struct VersionService: VersionServicing {
    func fetchVersions() async throws -> [String] {
        let url = URL(string: "https://ddragon.leagueoflegends.com/api/version.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([String].self, from: data)
    }
}

@MainActor
final class VersionViewModel: ObservableObject {
    @Published var currentVersion: String?
    @Published var allVersions: [String] = []
    @Published var errorMessage: String?
    
    private let service: VersionServicing
    
    init(service: VersionServicing) {
        self.service = service
    }
    
    func fetchVersions() async {
        do {
            let versions = try await service.fetchVersions()
            self.allVersions = versions
            self.currentVersion = versions.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
