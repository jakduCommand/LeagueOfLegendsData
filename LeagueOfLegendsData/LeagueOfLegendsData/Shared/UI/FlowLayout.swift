//
//  FlowLayout.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 11/19/25.
//
import SwiftUI

struct FlowLayout: Layout {
    let itemSpacing: CGFloat = 12
    let rowSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        let maxWidth = proposal.width ?? 1000
        
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if width + size.width + itemSpacing > maxWidth {
                width = 0
                height += rowHeight + rowSpacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            width += size.width + itemSpacing
        }
        
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            
            if x + size.width + itemSpacing > bounds.maxX {
                x = bounds.minX
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            
            sub.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + itemSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

