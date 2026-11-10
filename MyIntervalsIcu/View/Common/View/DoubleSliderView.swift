//
//  DoubleSliderView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import SwiftUI

private enum Constant {
    static let indicatorSize: CGFloat = 22.0
    static let fullIndicatorSize: CGFloat = indicatorSize * 2.0
    static let barCornerRadius: CGFloat = 1.5
    static let barHeight: CGFloat = 3.0
}

struct DoubleSliderView<LowerLabel: View, UpperLabel: View>: View {

    @Binding var lowerSelectionRangeAsPercent: Double?
    @Binding var upperSelectionRangeAsPercent: Double?
    let lowerLabel: () -> LowerLabel
    let upperLabel: () -> UpperLabel

    @State private var isLowerLabelShown = false
    @State private var isUpperLabelShown = false

    init(
        lowerSelectionRangeAsPercent: Binding<Double?>,
        upperSelectionRangeAsPercent: Binding<Double?>,
        @ViewBuilder lowerLabel: @escaping () -> LowerLabel = { EmptyView() },
        @ViewBuilder upperLabel: @escaping () -> UpperLabel = { EmptyView() }
    ) {
        self._lowerSelectionRangeAsPercent = lowerSelectionRangeAsPercent
        self._upperSelectionRangeAsPercent = upperSelectionRangeAsPercent
        self.lowerLabel = lowerLabel
        self.upperLabel = upperLabel
    }

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

            HStack(alignment: .midIndicator, spacing: .zero) {
                Color.clear.frame(width: leadingLocation)
                indicator {
                    isLowerLabelShown = false
                } onPanGestureChange: { float in
                    isLowerLabelShown = true

                    let updatedLeadingLocation = min(
                        max(leadingLocation + float, .zero),
                        proxy.size.width - trailingLocation - Constant.fullIndicatorSize
                    )
                    lowerSelectionRangeAsPercent = updatedLeadingLocation
                    / (proxy.size.width - Constant.indicatorSize)
                    upperSelectionRangeAsPercent = upperSelectionRangeAsPercent ?? 1.0
                }
                .popover(isPresented: $isLowerLabelShown) { lowerLabel() }
                
                Spacer()

                indicator {
                    isUpperLabelShown = false
                } onPanGestureChange: { float in
                    isUpperLabelShown = true

                    let updatedTrailingLocation = min(
                        max(trailingLocation - float, .zero),
                        proxy.size.width - leadingLocation - Constant.fullIndicatorSize
                    )
                    upperSelectionRangeAsPercent = 1 - updatedTrailingLocation / (
                        proxy.size.width - Constant.indicatorSize
                    )
                    lowerSelectionRangeAsPercent = lowerSelectionRangeAsPercent ?? .zero
                }
                .popover(isPresented: $isUpperLabelShown) { upperLabel() }
                Color.clear.frame(width: trailingLocation)
            }
            .background(alignment: Alignment(horizontal: .center, vertical: .midIndicator)) {
                RoundedRectangle(
                    cornerSize: CGSize(
                        width: Constant.barCornerRadius,
                        height: Constant.barCornerRadius
                    )
                )
                .size(
                    width: proxy.size.width - Constant.indicatorSize,
                    height: Constant.barHeight,
                    anchor: .center
                )
                .fill(.gray.opacity(0.25))
            }
            .background(alignment: Alignment(horizontal: .leadingBarIndicator, vertical: .midIndicator)) {
                RoundedRectangle(
                    cornerSize: CGSize(
                        width: Constant.barCornerRadius,
                        height: Constant.barCornerRadius
                    )
                )
                .fill(.blue.opacity(0.8))
                .frame(
                    width: max(
                        proxy.size.width - leadingLocation - trailingLocation - Constant.fullIndicatorSize,
                        .zero
                    ),
                    height: Constant.barHeight,
                    alignment: Alignment(horizontal: .leadingBarIndicator, vertical: .midIndicator)
                )
            }
        }
    }

    func indicator(
        onPanGestureEnd: @escaping () -> Void,
        onPanGestureChange: @escaping (CGFloat) -> Void
    ) -> some View {
        Circle()
            .stroke(Color.accentColor)
            .fill(Color.primary)
            .frame(
                width: Constant.indicatorSize,
                height: Constant.indicatorSize
            )
            .alignmentGuide(.midIndicator) { $0[VerticalAlignment.center] }
            .alignmentGuide(.leadingBarIndicator) { $0[HorizontalAlignment.center] }
            .gesture(
                DragGesture()
                    .onEnded { _ in  onPanGestureEnd() }
                    .onChanged { value in onPanGestureChange(value.translation.width) }
            )
    }
}

extension VerticalAlignment {
    struct MidIndicatorAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    static let midIndicator: Self = .init(MidIndicatorAlignment.self)
}

extension HorizontalAlignment {
    struct LeadingBarIndicatorAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }

    static let leadingBarIndicator: Self = .init(LeadingBarIndicatorAlignment.self)
}

#Preview {
    DoubleSliderView(
        lowerSelectionRangeAsPercent: .constant(0.5),
        upperSelectionRangeAsPercent: .constant(0.7),
        lowerLabel: { Text("Lower") },
        upperLabel: { Text("High") }
    )
}
