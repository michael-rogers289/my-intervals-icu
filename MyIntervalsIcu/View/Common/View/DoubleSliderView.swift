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
            let proxyHeight = proxy.size.height
            let proxyWidth = proxy.size.width

            let leadingLocation = proxyWidth * (lowerSelectionRangeAsPercent ?? .zero)
            let trailingLocation = proxyWidth * (upperSelectionRangeAsPercent ?? 1.0)

            ZStack {
                RoundedRectangle(
                    cornerSize: CGSize(
                        width: Constant.barCornerRadius,
                        height: Constant.barCornerRadius
                    )
                )
                .fill(.gray.opacity(0.25))
                .frame(
                    width: proxyWidth,
                    height: Constant.barHeight,
                )
                .position(x: proxyWidth / 2.0, y: proxyHeight / 2.0)

                RoundedRectangle(
                    cornerSize: CGSize(
                        width: Constant.barCornerRadius,
                        height: Constant.barCornerRadius
                    )
                )
                .fill(.blue.opacity(0.8))
                .frame(
                    width: trailingLocation - leadingLocation,
                    height: Constant.barHeight,
                )
                .position(
                    // we start at the center of the view then shift the center towards the trailing end based on
                    // the leading location, but also towards the leading end based on the trailing location.
                    // Subtracting the trailing location from the full width gives the difference in the location of
                    // since the trailing location is x% of the full width
                    x: (proxyWidth + leadingLocation - (proxyWidth - trailingLocation)) / 2.0,
                    y: proxyHeight / 2.0
                )

                indicator(label: lowerLabel, isLabelShown: $isLowerLabelShown) { location in
                    lowerSelectionRangeAsPercent = max(
                        min(
                            (location + leadingLocation),
                            trailingLocation - Constant.fullIndicatorSize
                        ),
                        .zero
                    ) / proxyWidth
                }
                .position(x: leadingLocation, y: proxyHeight / 2.0)
                .onTapGesture {
                    withAnimation {
                        isLowerLabelShown.toggle()
                    }
                }

                indicator(label: upperLabel, isLabelShown: $isUpperLabelShown) { location in
                    upperSelectionRangeAsPercent = max(
                        min(location + trailingLocation, proxyWidth),
                        leadingLocation + Constant.fullIndicatorSize
                        )
                    / proxyWidth
                }
                .position(x: trailingLocation, y: proxyHeight / 2.0)
                .onTapGesture {
                    withAnimation {
                        isUpperLabelShown.toggle()
                    }
                }
            }
        }
        .padding(.horizontal, Constant.indicatorSize)
    }

    func indicator(
        label: @escaping () -> some View,
        isLabelShown: Binding<Bool>,
        onPanGestureChange: @escaping (CGFloat) -> Void
    ) -> some View {
        Capsule()
            .stroke(Color.accentColor)
            .fill(Color.primary)
            .frame(
                width: Constant.fullIndicatorSize,
                height: Constant.indicatorSize
            )
            .popover(isPresented: isLabelShown) { label() }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in onPanGestureChange(value.location.x) }
                    .onEnded { _ in
                        isLabelShown.wrappedValue = true
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            isLabelShown.wrappedValue = false
                        }
                    }
            )
            .animation(.bouncy, value: isLabelShown.wrappedValue)
    }
}

#Preview {
    @Previewable @State var lower: Double? = 0.0
    @Previewable @State var upper: Double? = 1.0

    DoubleSliderView(
        lowerSelectionRangeAsPercent: $lower,
        upperSelectionRangeAsPercent: $upper,
        lowerLabel: { Text("Lower") },
        upperLabel: { Text("High") }
    )
}
