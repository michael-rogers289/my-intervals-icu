//
//  DoubleSliderView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import SwiftUI

struct DoubleSliderView: View {

    private enum Constant {
        static let indicatorSize: CGFloat = 22.0
        static let fullIndicatorSize: CGFloat = indicatorSize * 2.0
        static let barCornerRadius: CGFloat = 1.5
        static let barHeight: CGFloat = 3.0
    }

    @Binding var lowerSelectionRangeAsPercent: Double?
    @Binding var upperSelectionRangeAsPercent: Double?

    var body: some View {
        GeometryReader { proxy in
            let leadingLocation = min(
                max(proxy.size.width * (lowerSelectionRangeAsPercent ?? .zero), .zero),
                proxy.size.width - Constant.fullIndicatorSize
            )
            let trailingLocation = min(
                max(proxy.size.width * (1 - (upperSelectionRangeAsPercent ?? 1)), .zero),
                proxy.size.width - Constant.fullIndicatorSize
            )
            ZStack(alignment: .center) {
                RoundedRectangle(cornerSize: CGSize(width: Constant.barCornerRadius, height: Constant.barCornerRadius))
                    .size(
                        width: proxy.size.width - Constant.indicatorSize,
                        height: Constant.barHeight,
                        anchor: .center
                    )
                    .fill(.gray.opacity(0.25))

                HStack(alignment: .center, spacing: .zero) {
                    Color.clear.frame(width: leadingLocation)
                    indicator { float in
                        let updatedLeadingLocation = min(
                            max(leadingLocation + float, .zero),
                            proxy.size.width - trailingLocation - Constant.fullIndicatorSize
                        )
                        lowerSelectionRangeAsPercent = updatedLeadingLocation
                        / (proxy.size.width - Constant.indicatorSize)
                    }
                    RoundedRectangle(
                        cornerSize: CGSize(
                            width: Constant.barCornerRadius,
                            height: Constant.barCornerRadius
                        )
                    )
                        .size(
                            width: proxy.size.width - leadingLocation - trailingLocation - Constant.fullIndicatorSize,
                            height: Constant.barHeight,
                            anchor: .center
                        )
                        .fill(.blue.opacity(0.8))

                    indicator { float in
                        let updatedTrailingLocation = min(
                            max(trailingLocation - float, .zero),
                            proxy.size.width - leadingLocation - Constant.fullIndicatorSize
                        )
                        upperSelectionRangeAsPercent = 1 - updatedTrailingLocation / (
                            proxy.size.width - Constant.indicatorSize
                        )
                    }
                    Color.clear.frame(width: trailingLocation)
                }
            }
        }.frame(minHeight: Constant.fullIndicatorSize, idealHeight: Constant.fullIndicatorSize)
    }

    func indicator(
        onPanGestureChange: @escaping (CGFloat) -> Void
    ) -> some View {
        Circle()
            .stroke(Color.black)
            .fill(Color.white)
            .frame(
                width: Constant.indicatorSize,
                height: Constant.indicatorSize,
            )
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        onPanGestureChange(value.translation.width)
                    })
            )

    }
}

#Preview {
    DoubleSliderView(lowerSelectionRangeAsPercent: .constant(0.35), upperSelectionRangeAsPercent: .constant(0.85))
}
