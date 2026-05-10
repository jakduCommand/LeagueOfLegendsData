//
//  RuneExtractor.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 4/30/26.
//

struct RuneExtractor {
    func extractRune(_ participant: ParticipantDto) -> [Int] {
        let perks = participant.perks
        let styles = perks.styles
        
        var result = [Int]()
        
        for style in styles {
            for selection in style.selections {
                result.append(selection.perk)
            }
        }
        
        return result
    }
    
    func extractStatRune(_ participant: ParticipantDto) -> [Int] {
        let perks = participant.perks
        let statPerks = perks.statPerks
        
        var result = [Int]()
        
        result.append(statPerks.defense)
        result.append(statPerks.flex)
        result.append(statPerks.offense)
        
        return result
    }
}
