//
//  StreamMapView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import FactoryKit
import SwiftUI

enum ActivityDetailNavigationElement {
    case mapDetail
}

struct StreamMapView: View {

    @Namespace private var activityDetailNamespace

    @State private var viewModel = Container.shared.mapViewModel.resolve()
    @State private var selectionViewmModel = Container.shared.selectionViewModel.resolve()
    @Environment(NavigationViewModel.self) private var navigationViewModel

    let detailViewModel: ActivityDetailViewModel

    var body: some View {
        VStack {
            Group {
                if let mapViewData = viewModel.viewData {
                    ActivityMapView(viewData: mapViewData)
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                navigationViewModel.push(ActivityDetailNavigationElement.mapDetail)
                            } label: {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                            }
                            .tint(.white)
                            .buttonStyle(GlassButtonStyle())
                            .accessibilityLabel("Expand Map")
                            .padding(.spacingMedium)
                        }
                        .matchedTransitionSource(id: "activity_map", in: activityDetailNamespace)
                } else {
                    ProgressView {
                        Text("Loading map...")
                    }
                }
            }
            .aspectRatio(1.0 / 0.4, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 3.0, height: 3.0)))
            HStack(alignment: .center, spacing: .spacingMedium) {
                DoubleSliderView(
                    lowerSelectionRangeAsPercent: $selectionViewmModel.firstSelectionRangeAsPercent,
                    upperSelectionRangeAsPercent: $selectionViewmModel.secondSelectionRangeAsPercent,
                ) {
                    if let start = detailViewModel.timeRangeViewData?.start {
                        Text(start, format: .timeDuration)
                    }
                } upperLabel: {
                    if let end = detailViewModel.timeRangeViewData?.end {
                        Text(end, format: .timeDuration)
                    }
                }

                Button {
                    selectionViewmModel.resetSelectionRange()
                } label: {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .padding(.spacingSmall)
                        .frame(minWidth: 44.0, idealWidth: 44.0, minHeight: 44.0)
                        .fixedSize()
                }
                .tint(Color.primary)
                .accessibilityLabel("Clear Selected Workout Time Range")
                .disabled(
                    selectionViewmModel.secondSelectionRangeAsPercent == nil &&
                    selectionViewmModel.firstSelectionRangeAsPercent == nil
                )
            }

        }
        .navigationDestination(for: ActivityDetailNavigationElement.self) { element in
            switch element {
            case .mapDetail:
                FullScreenMapView()
                    .navigationTransition(.zoom(sourceID: "activity_map", in: activityDetailNamespace))

            }
        }
    }
}
