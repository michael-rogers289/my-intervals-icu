//
//  DateSelector.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/15/26.
//

import SwiftUI

struct DateSelector: View {
    
    let totalDistance: Double
    let displayDate: Date
    let onPreviousSelected: () -> Void
    let onNextSelected: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPreviousSelected) {
                Image(systemName: "chevron.left")
            }
            VStack {
                Text(displayDate, style: .date)
                Text(
                    Measurement(value: totalDistance, unit: UnitLength.kilometers),
                    format: .measurement(
                        width: .abbreviated,
                        usage: .asProvided,
                        numberFormatStyle: .number.precision(.fractionLength(1))
                    )
                )
            }
            
            Button(action: onNextSelected) {
                Image(systemName: "chevron.right")
            }
        }.buttonStyle(.glass)
    }
    
}
