//
//  DoubleSliderView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import SwiftUI

struct DoubleSliderView: View {

    static let indicatorSize: CGFloat = 22.0

    @State var leadingLocation: CGFloat = .zero
    @State var trailingLocation: CGFloat = .zero

    var fullIndicatorSize: CGFloat {
        Self.indicatorSize * 2.0
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                RoundedRectangle(cornerSize: CGSize(width: 1.5, height: 1.5))
                    .size(
                        width: proxy.size.width - Self.indicatorSize,
                        height: 3.0,
                        anchor: .center
                    )
                    .fill(.gray.opacity(0.25))

                HStack(alignment: .center, spacing: .zero) {
                    Color.clear.frame(width: leadingLocation)
                    indicator { float in
                        leadingLocation = min(
                            max(leadingLocation + float, .zero),
                            proxy.size.width - trailingLocation - fullIndicatorSize
                        )
                    }
                    RoundedRectangle(cornerSize: CGSize(width: 1.5, height: 1.5))
                        .size(
                            width: proxy.size.width - leadingLocation - trailingLocation - fullIndicatorSize,
                            height: 3.0,
                            anchor: .center
                        )
                        .fill(.blue.opacity(0.8))

                    indicator { float in
                        trailingLocation = min(
                            max(trailingLocation - float, .zero),
                            proxy.size.width - leadingLocation - fullIndicatorSize
                        )
                    }
                    Color.clear.frame(width: trailingLocation)
                }
            }
        }.frame(minHeight: fullIndicatorSize, idealHeight: fullIndicatorSize)
    }

    func indicator(
        onPanGestureChange: @escaping (CGFloat) -> Void
    ) -> some View {
        Circle()
            .stroke(Color.black)
            .fill(Color.white)
            .frame(
                width: Self.indicatorSize,
                height: Self.indicatorSize,
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
    DoubleSliderView()
}
