//
//  ActivityDtoToActivityEntityMapper.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/13/25.
//

import Foundation
import SwiftProtobuf

nonisolated
extension ActivityDto {
    
    func mapToActivity() -> Activity? {
        guard let startDate else { return nil }
        let endDate: Date? = if let elapsedTime {
            CalendarRepository.date(byAddingSeconds: elapsedTime, to: startDate)
        } else {
            nil
        }
        return Activity(
            id: self.id,
            startDate: startDate,
            endDate: endDate,
            distince: self.distance ?? Double.zero,
            elapsedTime: elapsedTime,
            type: type,
            averageCadence: averageCadence,
            calories: calories,
            polarizationIndex: polarizationIndex,
            maxSpeed: maxSpeed,
            averageSpeed: averageSpeed,
            normalizedWatts: icuWeightedAvgWatts,
            icuAverageWatts: icuAverageWatts,
            deviceWatts: deviceWatts,
            maxHeartRate: maxHeartRate,
            averageHeartRate: averageHeartRate
        )
    }
    
    func mapToHeartRateZones() -> [ActivityHeartRateZone] {
        guard icuHeartRateZones.count > 0 || icuHeartRateZones.count == icuHrZoneTimes.count else {
            print("HeartRateMapping", "Incorrect hr zones \(icuHeartRateZones.count) or times size \(icuHrZoneTimes.count)")
            return []
        }
        return (0..<icuHeartRateZones.count).map {
            ActivityHeartRateZone(
                id: "\(id)_\($0)",
                zone: $0,
                lowerBound: icuHeartRateZones[max($0 - 1, 0)],
                upperBound: icuHeartRateZones[$0],
                secondsInZone: icuHrZoneTimes[$0],
                activityId: id
            )
        }
    }
    
    func mapToPowerZones() -> [ActivityPowerZone] {
        icuZoneTimes.compactMap { powerZoneTimeDto in
            guard let zone = Int(powerZoneTimeDto.id.filter { $0.isNumber }) else {
                return nil
            }
            return ActivityPowerZone(
                id: id + "_\(zone)",
                zone: zone,
                secondsInZone: powerZoneTimeDto.timeInZone,
                activityId: id
            )
        }
    }
    
    func mapToSummaryChartBars() -> [SummaryChartBar] {
        guard let data = Data(base64Encoded: skylineChartBytes),
              let chart = try? SkylineChart(serializedBytes: data),
              chart.width.count == chart.intensity.count && chart.width.count == chart.zone.count else {
            return []
        }
        var previousWidth: Int32 = 0
        
        return chart.width.enumerated().map { index, width in
            let chartBar = SummaryChartBar(
                id: "\(id)_\(index)",
                xChartPosition: Int(previousWidth),
                width: Int(width),
                intensity: Int(chart.intensity[index]),
                zone: Int(chart.zone[index]),
                totalNumZones: Int(chart.numZones),
                activityId: id
            )
            
            previousWidth += width
            
            return chartBar
        }
        
    }
    
}
