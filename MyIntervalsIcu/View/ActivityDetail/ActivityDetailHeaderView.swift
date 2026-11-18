//
//  ActivityDetailHeaderView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/13/26.
//

import SwiftUI

struct ActivityDetailHeaderView: View {

    let viewData: ActivityOverviewViewData

    var body: some View {
        GroupBox {
            CascadingGridLayout(
                cellSpacing: .spacingMedium,
            ) {
                let measurementCount = viewData.measurementViewData.count
                ForEach(0..<measurementCount, id: \.self) { index in
                    let measurementViewData = viewData.measurementViewData[index]
                    let title = Text(measurementViewData.title)
                    let measurement = Text(
                        measurementViewData.measurement.measurement,
                        format: measurementViewData.measurement.format
                    )
                    HStack(alignment: .center, spacing: .spacingSmall) {
                        Text("\(title): \(measurement)")
                            .font(.callout)
                            .padding(.vertical, .spacingSmall)
                        Divider()
                    }
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: .spacingSmall) {
                Text("\(Text(viewData.title)): \(Text(viewData.startDate, style: .date))")
                    .font(.title)
                Text("Duration: \(Text(viewData.startDate..<viewData.endDate, format: .timeDuration))")
                    .font(.title2)
                Divider()
                    .padding(.vertical, .spacingSmall)
            }

        }
        	.padding(.spacingMedium)
    }
}

#Preview {
    ActivityDetailHeaderView(
        viewData: ActivityOverviewViewData(
            title: "Outdoor Ride",
            startDate: Date(),
            endDate: Date(timeIntervalSinceNow: 60 * 60 * 1.5),
            measurementViewData: [
                .init(
                    title: "Distance",
                    measurement: ActivityMeasurement(
                        measurement: Measurement(
                            value: 34.5,
                            unit: UnitLength.kilometers
                        )
                    )
                ),
                .init(
                    title: "Distance also longer",
                    measurement: ActivityMeasurement(
                        measurement: Measurement(
                            value: 34.5,
                            unit: UnitLength.kilometers
                        )
                    )
                ),
                .init(
                    title: "Distance But longer",
                    measurement: ActivityMeasurement(
                        measurement: Measurement(
                            value: 34.5,
                            unit: UnitLength.kilometers
                        )
                    )
                ),
                .init(
                    title: "Distance is this long",
                    measurement: ActivityMeasurement(
                        measurement: Measurement(
                            value: 34.5,
                            unit: UnitLength.kilometers
                        )
                    )
                ),
                .init(
                    title: "Distance",
                    measurement: ActivityMeasurement(
                        measurement: Measurement(
                            value: 34.5,
                            unit: UnitLength.kilometers
                        )
                    )
                )
            ]
        )
    )
}
