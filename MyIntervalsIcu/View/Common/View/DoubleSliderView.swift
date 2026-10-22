//
//  DoubleSliderView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import SwiftUI

struct DoubleSliderView: View {

    struct Selection: Equatable {
        static let `default` = Selection(upperSelectionRangeAsPercent: 1.0, lowerSelectionRangeAsPercent: 0.0)
        let upperSelectionRangeAsPercent: Double
        let lowerSelectionRangeAsPercent: Double
    }

    private enum Constant {
        static let indicatorSize: CGFloat = 22.0
        static let fullIndicatorSize: CGFloat = indicatorSize * 2.0
        static let barCornerRadius: CGFloat = 1.5
        static let barHeight: CGFloat = 3.0
    }

    @State private var leadingLocation: CGFloat = .zero
    @State private var trailingLocation: CGFloat = .zero

    @Binding var selection: Selection

    init(selection: Binding<Selection>) {
        self._selection = selection
    }

    var body: some View {
        GeometryReader { proxy in
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
                        leadingLocation = min(
                            max(leadingLocation + float, .zero),
                            proxy.size.width - trailingLocation - Constant.fullIndicatorSize
                        )
                        selection = Selection(
                            upperSelectionRangeAsPercent: selection.upperSelectionRangeAsPercent,
                            lowerSelectionRangeAsPercent: leadingLocation / (proxy.size.width - Constant.indicatorSize)
                        )
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
                        trailingLocation = min(
                            max(trailingLocation - float, .zero),
                            proxy.size.width - leadingLocation - Constant.fullIndicatorSize
                        )
                        selection = Selection(
                            upperSelectionRangeAsPercent: 1 - trailingLocation / (
                                proxy.size.width - Constant.indicatorSize
                            ),
                            lowerSelectionRangeAsPercent: selection.lowerSelectionRangeAsPercent
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
    DoubleSliderView(selection: Binding.constant(DoubleSliderView.Selection.default))
}
