//
//  ActivityMeasurement.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/16/26.
//

import Foundation

struct ActivityMeasurement {
    let measurement: Measurement<Dimension>
    let format: Measurement<Dimension>.FormatStyle = Measurement<Dimension>.FormatStyle(
        width: .narrow,
        usage: .asProvided,
        numberFormatStyle: .number.precision(.fractionLength(1))
    )
}
