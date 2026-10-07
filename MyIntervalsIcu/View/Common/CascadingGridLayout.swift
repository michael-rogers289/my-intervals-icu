//
//  CascadingGridLayout.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/6/26.
//

import SwiftUI

struct CascadingGridLayout: Layout {
    
    struct Cache {
        
        struct Row {
            let rowNumber: Int
            private(set)var sizes: [CGSize] = []
            
            var maxHeight: CGFloat {
                return sizes.map { $0.height }.max() ?? .zero
            }
            
            mutating func append(_ size: CGSize) {
                sizes.append(size)
            }
        }
        
        var rows: [Row] = []
    }
    
    let cellSpacing: CGFloat
    
    init(cellSpacing: CGFloat = .spacingSmall) {
        self.cellSpacing = cellSpacing
    }
    
    func makeCache(subviews: Subviews) -> Cache {
        Cache()
    }
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let idealSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let proposedWidth = proposal.replacingUnspecifiedDimensions().width
    
        var currentRowWidth: CGFloat = proposedWidth
        var rows = [Cache.Row(rowNumber: 1)]
        
        idealSizes.forEach { size in
            
            let computedWidth = size.width + cellSpacing * 2.0
            
            // Can the current row fit a view & the end spacing?
            currentRowWidth -= computedWidth
            
            if currentRowWidth <= .zero {
                // Start new row
                let currentRowNumber = rows[rows.count - 1].rowNumber
                rows.append(
                    Cache.Row(rowNumber: currentRowNumber + 1, sizes: [size])
                )
                
                // Reset state
                currentRowWidth = proposedWidth - computedWidth
            } else {
                let lastIndex = rows.count - 1
                rows[lastIndex].append(size)
            }
        }
        
        cache.rows = rows
        
        let heightSpacing = CGFloat(rows.count + 1) * cellSpacing
        let sumMaxHeight: CGFloat = rows
            .map { $0.maxHeight }
            .reduce(0.0, { $0 + $1 })
        
        return CGSize(
            width: proposedWidth,
            height: heightSpacing + sumMaxHeight
        )
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        
        let flattenedSubviews = cache.rows.flatMap { row in row.sizes.map { (row.rowNumber, $0) } }
        var originY = bounds.origin.y + cellSpacing
        var originX = bounds.origin.x + cellSpacing
        
        var currentRow = flattenedSubviews.first?.0 ?? 0
        
        subviews.enumerated().forEach { index, subview in
            let computedSubview = flattenedSubviews[index]
            
            // Move the originPoints
            if currentRow != computedSubview.0 {
                originX = bounds.origin.x + cellSpacing
                originY += cache.rows[currentRow].maxHeight + cellSpacing
                currentRow = computedSubview.0
            }
            
            subview.place(
                at: CGPoint(
                    x: originX,
                    y: originY,
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(
                    width: computedSubview.1.width,
                    height: computedSubview.1.height,
                )
            )
            
            originX += computedSubview.1.width + cellSpacing
        }
    }
}
