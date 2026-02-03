//
//  FileManagerView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/25/25.
//
import SwiftUI

struct FileManagerView: View {
    @StateObject private var fmVM = FileManagerViewModel()
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text("Saved LeagueData Files")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("Refresh") { fmVM.loadFiles() }
                Button("Cleare All", role: .destructive) { fmVM.clearAll() }
            }
            .padding(.horizontal)
            
            Divider()
            
            if fmVM.files.isEmpty {
                Text("No saved files found.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(fmVM.files) { file in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(file.name)
                                .font(.headline)
                            Text("Modified: \(file.modified.formatted())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Size: \(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Open") { fmVM.openFile(file) }
                        Button(role: .destructive) {
                            fmVM.deleteFile(file)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .padding()
        .alert("Error", isPresented: .constant(fmVM.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                fmVM.errorMessage = nil
            }
        } message: {
            Text(fmVM.errorMessage ?? "")
        }
    }
}
