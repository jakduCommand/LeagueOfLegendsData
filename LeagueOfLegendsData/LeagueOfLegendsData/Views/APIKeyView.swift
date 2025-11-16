//
//  APIKeyView.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/7/25.
//
import SwiftUI

struct APIKeyView: View {
    @State private var apiKey: String = ""
    @State private var showKey: Bool = false
    @State private var showKey2: Bool = false
    @State private var statusMessage: String = ""
    @State private var showDeleteAlert = false
    @State private var showSaveAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Riot API Key")
                .font(.headline)
            
            HStack {
                if showKey {
                    TextField("Enter API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    SecureField("Enter API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: { showKey.toggle() }) {
                    Image(systemName: showKey ? "eye.slash" : "eye")
                }
                .buttonStyle(.borderless)
                .help(showKey ? "Hide key" : "Show key")
            }
            
            HStack(spacing: 16) {
                Button("Save Key") {
                    showSaveAlert = true
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
                .alert("Save API Key?", isPresented: $showSaveAlert) {
                    Button("Save", role: .none) {
                        KeychainService.delete()
                        KeychainService.save(key: apiKey)
                        statusMessage = "API key saved securely."
                    }
                    Button("Cancel", role: .cancel) { }
                    
                } message: {
                    Text("Saving API Key will delete privious key.")
                }
                
                Button("Delete Key") {
                    showDeleteAlert = true
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .padding(.top, 8)
                .alert("Delete API Key?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        KeychainService.delete()
                        apiKey = ""
                        statusMessage = "API key deleted"
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This action cannot be undone")
                }
            }
            
            
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            
            // Show current saved key
            if let savedKey = KeychainService.load(), !savedKey.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current saved key:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(showKey2 ? savedKey : String(repeating: "•", count: savedKey.count))
                            .font(.system(.body, design: .monospaced))
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        
                        Button(action: { showKey2.toggle() }) {
                            Image(systemName: showKey2 ? "eye.slash" : "eye")
                        }
                        .buttonStyle(.borderless)
                        .help(showKey2 ? "Hide key" : "Show key")
                    }
                    
                }
                .padding(.top, 8)
            }
            
            Spacer()
        
        }
        .padding()
        .onAppear {
            if let savedKey = KeychainService.load() {
                apiKey = savedKey
            }
        }
    }
}
