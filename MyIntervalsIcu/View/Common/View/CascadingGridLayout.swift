//
//  CascadingGridLayout.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/6/26.
//

import SwiftUI

struct CascadingGridLayout: Layout {

    struct Cache {

        struct RowItemSize {
            let height: CGFloat
            let width: CGFloat
            let widthAdjustment: CGFloat

            init(height: CGFloat, width: CGFloat, widthAdjustment: CGFloat = .zero) {
                self.height = height
                self.width = width
                self.widthAdjustment = widthAdjustment
            }
        }

        struct Row {
            let rowNumber: Int
            private(set)var sizes: [RowItemSize] = []

            var maxHeight: CGFloat {
                return sizes.map { $0.height }.max() ?? .zero
            }

            mutating func append(_ size: RowItemSize) {
                sizes.append(size)
            }

            mutating func adjustSizeWidths(by additionalSize: CGFloat) {
                sizes = sizes.map {
                    RowItemSize(
                        height: $0.height,
                        width: $0.width + additionalSize,
                        widthAdjustment: additionalSize
                    )
                }
            }
        }

        var rows: [Row] = []
    }

    let cellSpacing: CGFloat
    let columns: Int
    let fillsAvailableWidth: Bool

    init(
        cellSpacing: CGFloat = .spacingSmall,
        columns: Int = Int.max,
        fillsAvailableWidth: Bool = false
    ) {
        self.cellSpacing = cellSpacing
        self.columns = columns
        self.fillsAvailableWidth = fillsAvailableWidth
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

        idealSizes.enumerated().forEach { index, size in

            let computedWidth = size.width + cellSpacing * 2.0

            // Can the current row fit a view & the end spacing?
            currentRowWidth -= computedWidth
            let lastIndex = rows.count - 1

            func fillAvailableWidthIfNeeded(addsBackWidth: Bool) {
                guard fillsAvailableWidth else { return }
                // Need to add back the removed width
                let leftoverRowWidth = if addsBackWidth {
                    currentRowWidth + computedWidth
                } else {
                    currentRowWidth
                }
                let additionalSizePerItem = leftoverRowWidth / rows[lastIndex].sizes.count.toDouble()
                rows[lastIndex].adjustSizeWidths(by: additionalSizePerItem)
            }

            if currentRowWidth <= .zero || (rows[lastIndex].sizes.count == columns) {
                // Check to fill space if we've run out
                fillAvailableWidthIfNeeded(addsBackWidth: true)

                // Start new row
                let currentRowNumber = rows[lastIndex].rowNumber
                rows.append(
                    Cache.Row(rowNumber: currentRowNumber + 1, sizes: [size.asRowItemSize])
                )

                // Reset state
                currentRowWidth = proposedWidth - computedWidth
            } else {

                rows[lastIndex].append(size.asRowItemSize)

                if index == subviews.count - 1 {
                    fillAvailableWidthIfNeeded(addsBackWidth: false)
                }
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
                    x: originX + computedSubview.1.widthAdjustment / 2.0,
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

private extension CGSize {

    var asRowItemSize: CascadingGridLayout.Cache.RowItemSize {
        .init(height: height, width: width)
    }

}
