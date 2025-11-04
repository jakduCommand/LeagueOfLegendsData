//
//  versionView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 10/25/25.
//
import SwiftUI

struct VersionView: View {
    @EnvironmentObject var versionVM: VersionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                if versionVM.isLoading {
                    ProgressView("Loading versions…")
                } else if let error = versionVM.errorMessage {
                    Text("Error: \(error)").foregroundColor(.red)
                } else if let version = versionVM.currentVersion {
                    Text("Current version: \(version)").font(.headline)
                } else {
                    Text("No current version found").foregroundColor(.secondary)
                }
            }
            
            List(versionVM.allVersions, id: \.self) { ver in
                Text(ver)
            }
            
            if let error = versionVM.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .task {
            await versionVM.load()
            print(versionVM.currentVersion ?? "No version")
        }
    }
}
