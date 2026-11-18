//
//  ActivityOverviewViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/16/26.
//

import Foundation

struct ActivityOverviewViewData {

    struct MeasurementViewData {
        let title: String
        let measurement: ActivityMeasurement
    }

    let title: String
    let startDate: Date
    let endDate: Date
    let measurementViewData: [MeasurementViewData]
}
