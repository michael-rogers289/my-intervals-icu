//
//  StreamSummaryViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/9/26.
//

import Foundation

protocol StreamSummaryViewData {
    associatedtype UnitType: Dimension
    var type: TimeSeriesStreamType { get }
    var min: Measurement<UnitType> { get }
    var average: Measurement<UnitType> { get }
    var max: Measurement<UnitType> { get }
    var format: Measurement<UnitType>.FormatStyle { get }
}

struct AStreamSummaryViewData<UnitType : Dimension> : StreamSummaryViewData {
    let type: TimeSeriesStreamType
    let min: Measurement<UnitType>
    let average: Measurement<UnitType>
    let max: Measurement<UnitType>
    let format:Measurement<UnitType>.FormatStyle
    
    init(
        type: TimeSeriesStreamType,
        min: Measurement<UnitType>,
        average: Measurement<UnitType>,
        max: Measurement<UnitType>,
        format: Measurement<UnitType>.FormatStyle = Measurement<UnitType>.FormatStyle(
            width: .narrow,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(1))
        )
    ){
        self.type = type
        self.min = min
        self.average = average
        self.max = max
        self.format = format
    }
}
