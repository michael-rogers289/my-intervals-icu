//
//  ActivityMapView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/24/26.
//

import MapKit
import SwiftUI

struct ActivityMapView: View {

    let viewData: MapViewData

    var body: some View {
        Map {
            MapPolyline(points: viewData.selectedMapMarks)
                .stroke(.blue, lineWidth: 5.0)

            Group {
                MapPolyline(points: viewData.lowerExcludedMapMarks)
                MapPolyline(points: viewData.upperExcludedMapMarks)
            }.stroke(.gray, lineWidth: 2.0)
        }
        .mapControlVisibility(.automatic)
    }
}
