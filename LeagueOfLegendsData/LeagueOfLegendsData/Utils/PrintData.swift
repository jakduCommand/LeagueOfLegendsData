//
//  PrintData.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/6/25.
//
import Foundation

struct PrintData {
    func printDecoded<T: Decodable>(_ jsonData: Data, as type: T.Type) {
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: jsonData)
            dump(decoded)
        } catch {
            print("Decoding failed:", error)
        }
        
    }
}
