//
//  MapViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/24/26.
//

import Foundation
import MapKit

struct MapViewData {
    let lowerExcludedMapMarks: [MKMapPoint]
    let upperExcludedMapMarks: [MKMapPoint]
    let selectedMapMarks: [MKMapPoint]

    init(
        lowerExcludedMapMarks: [MKMapPoint] = [],
        upperExcludedMapMarks: [MKMapPoint] = [],
        selectedMapMarks: [MKMapPoint] = []
    ) {
        self.lowerExcludedMapMarks = lowerExcludedMapMarks
        self.upperExcludedMapMarks = upperExcludedMapMarks
        self.selectedMapMarks = selectedMapMarks
    }
}
