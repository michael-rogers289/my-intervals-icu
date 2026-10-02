//
//  ActivitySummaryInfoView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/30/26.
//

import Foundation
import SwiftUI

struct ActivitySummaryInfoViewData {
    let title: String
    let startTime: String
    let elapsedTime: String
    let distanceInKilometers: Measurement<UnitLength>
}

struct ActivitySummaryInfoView : View {
    
    let viewData: ActivitySummaryInfoViewData
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingSmall) {
            Text("\(viewData.title): \(viewData.startTime)")
                .font(.headline)
            
            Text("Duration: \(viewData.elapsedTime)")
            
            Text(
                viewData.distanceInKilometers,
                format: .measurement(
                    width: .abbreviated,
                    usage: .asProvided,
                    numberFormatStyle: .number.precision(.fractionLength(1))
                )
            )
            
        }
        .multilineTextAlignment(.leading)
        .font(.subheadline)
    }
}
