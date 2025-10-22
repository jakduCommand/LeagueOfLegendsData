//
//  MainViewModel.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/21/25.
//
import Foundation
import Combine
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    let versionViewModel: VersionViewModel
    
    @Published var currentVersion: String?
    @Published var allVersions: [String] = []
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(service: VersionServicing) {
        versionViewModel = VersionViewModel(service: service)
        
        versionViewModel.$currentVersion
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentVersion)
        
        versionViewModel.$allVersions
            .receive(on: DispatchQueue.main)
            .assign(to: &$allVersions)
        
        versionViewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$errorMessage)
        
        Task {
            await versionViewModel.fetchVersions()
        }
    }
    
    public func refreshVersions() {
        Task {
            await versionViewModel.fetchVersions()
        }
    }
}
