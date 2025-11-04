//
//  VersionViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/21/25.
//
import Foundation
import Combine

@MainActor
final class VersionViewModel: ObservableObject {
    @Published var currentVersion: String?
    @Published var allVersions: [String] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    private let service: VersionServicing
    
    init(service: VersionServicing) {
        self.service = service
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let versions = try await service.fetchVersions()
            self.allVersions = versions
            self.currentVersion = versions.first
            self.errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
