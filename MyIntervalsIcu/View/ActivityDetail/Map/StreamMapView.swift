//
//  StreamMapView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import SwiftUI
import MapKit

struct StreamMapView: View {

    @State private var viewModel = StreamMapViewModel()

    var body: some View {
        Group {
            if viewModel.mapMarks.isEmpty {
                ProgressView()
            } else {
                Map {
                    MapPolyline(points: viewModel.mapMarks)
                        .stroke(.blue, lineWidth: 5.0)
                }
                .mapControlVisibility(.hidden)
            }
        }
        .aspectRatio(1.0 / 0.4, contentMode: .fill)
    }
}
