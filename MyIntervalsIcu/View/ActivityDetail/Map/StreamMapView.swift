//
//  StreamMapView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import FactoryKit
import MapKit
import SwiftUI

struct StreamMapView: View {

    @State private var viewModel = StreamMapViewModel()
    @State private var selectionViewmModel = Container.shared.activityDetailViewModel.resolve()

    var body: some View {
        VStack {
            Group {
                if viewModel.viewData.selectedMapMarks.isEmpty {
                    ProgressView()
                } else {
                    Map {
                        MapPolyline(points: viewModel.viewData.selectedMapMarks)
                            .stroke(.blue, lineWidth: 5.0)

                        Group {
                            MapPolyline(points: viewModel.viewData.lowerExcludedMapMarks)
                            MapPolyline(points: viewModel.viewData.upperExcludedMapMarks)
                        }.stroke(.gray, lineWidth: 2.0)
                    }
                    .disabled(true)
                    .mapControlVisibility(.hidden)
                }
            }
            .aspectRatio(1.0 / 0.4, contentMode: .fill)

            DoubleSliderView(
                lowerSelectionRangeAsPercent: $selectionViewmModel.firstSelectionRangeAsPercent,
                upperSelectionRangeAsPercent: $selectionViewmModel.secondSelectionRangeAsPercent
            )
        }
    }
}
