//
//  Unit+Measurement.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/10/26.
//

import Foundation

extension UnitFrequency {
    static let rotationsPerMinute = UnitFrequency(
        symbol: "rpm",
        converter: UnitConverterLinear(coefficient: 1 / 60.0)
    )
    
    static let heartBeatsPerMinute = UnitFrequency(
        symbol: "bpm",
        converter: UnitConverterLinear(coefficient: 1 / 60.0)
    )
    
    func formatter(value: Double) -> some FormatStyle {
        Measurement<UnitFrequency>.FormatStyle(width: .narrow, usage: .asProvided, numberFormatStyle: .number.precision(.significantDigits(2)))
    }
}

class UnitTorque : Dimension, @unchecked Sendable {
    static let newtonMeter = UnitTorque(symbol: "Nm", converter: UnitConverterLinear(coefficient: 1.0))
    static let footPounds = UnitTorque(symbol: "lbf-ft", converter: UnitConverterLinear(coefficient: 0.7375621493))
    
    override class func baseUnit() -> Self {
        Self.newtonMeter as! Self
    }
}
