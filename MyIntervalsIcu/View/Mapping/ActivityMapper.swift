//
//  ActivityMapper.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/30/26.
//

import FactoryKit
import Foundation

struct ActivityMapper {

    @Injected(\.calendarRepository)
    private var calendarRepository

    func map(
        activity: Activity,
    ) -> ActivitySummaryInfoViewData {
        ActivitySummaryInfoViewData(
            title: activity.type ?? "Activity",
            startTime: calendarRepository.getTime(from: activity.startDate),
            elapsedTime: calendarRepository.formatInterval(
                from: activity.startDate,
                to: activity.endDate ?? activity.startDate
            ) ?? "",
            distanceInKilometers: Measurement(
                value: activity.distince,
                unit: .meters
            ).converted(to: UnitLength.kilometers),
        )
    }

    func map(_ activity: Activity) -> ActivityOverviewViewData {
        ActivityOverviewViewData(
            title: activity.type ?? "Activity",
            startDate: activity.startDate,
            endDate: activity.endDate ?? activity.startDate,
            measurementViewData: measurementViewData(from: activity),
        )
    }

    // swiftlint:disable:next function_body_length
    private func measurementViewData(from activity: Activity) -> [ActivityOverviewViewData.MeasurementViewData] {
        [
            measurementViewData(
                named: "Distance",
                value: activity.distince,
                and: UnitLength.meters,
                convertedTo: UnitLength.kilometers
            ),
            measurementViewData(
                named: "Calories",
                value: activity.calories?.toDouble(),
                and: UnitEnergy.calories
            ),
            measurementViewData(
                named: "Avg. Cadence",
                value: activity.averageCadence,
                and: UnitFrequency.rotationsPerMinute
            ),
            measurementViewData(
                named: "Max Speed",
                value: activity.maxSpeed,
                and: UnitSpeed.metersPerSecond,
                convertedTo: UnitSpeed.kilometersPerHour
            ),
            measurementViewData(
                named: "Avg. Speed",
                value: activity.averageSpeed,
                and: UnitSpeed.metersPerSecond,
                convertedTo: UnitSpeed.kilometersPerHour
            ),
            measurementViewData(
                named: "Normalized Power",
                value: activity.normalizedWatts?.toDouble(),
                and: UnitPower.watts
            ),
            measurementViewData(
                named: "ICU Avg. Power",
                value: activity.icuAverageWatts?.toDouble(),
                and: UnitPower.watts
            ),
            measurementViewData(
                named: "Activity FTP",
                value: activity.ftp?.toDouble(),
                and: UnitPower.watts
            ),
            measurementViewData(
                named: "Max Heart Rate",
                value: activity.maxHeartRate?.toDouble(),
                and: UnitFrequency.heartBeatsPerMinute
            ),
            measurementViewData(
                named: "Avg. Heart Rate",
                value: activity.averageHeartRate?.toDouble(),
                and: UnitFrequency.heartBeatsPerMinute
            )
        ]
            .compactMap { $0 }
    }

    private func measurementViewData(
        named title: String,
        value: Double?,
        and dimension: Dimension,
        convertedTo conversionDimension: Dimension? = nil
    ) -> ActivityOverviewViewData.MeasurementViewData? {
        guard let value else { return nil }
        let measurement = Measurement(
            value: value,
            unit: dimension
        )

        return ActivityOverviewViewData.MeasurementViewData(
            title: title,
            measurement: ActivityMeasurement(
                measurement: conversionDimension.map {
                    measurement.converted(to: $0)
                } ?? measurement
            )
        )
    }

}
