//
//  TimeSeriesStreamType.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/8/26.
//

import SwiftUI

enum TimeSeriesStreamType: Int, CaseIterable {
    case watts = 1
    case heartrate
    case cadence
    case coreTemperature
    case skinTemperature
    case smoothVelocity
    case altitude
    case torque
    case temp
    case leftRightBalance
    case leftPedalSmoothness
    case rightPedalSmoothness
    case leftTorqueEffectiveness
    case rightTorqueEffectiveness
    case verticalSpeed

    // swiftlint:disable:next cyclomatic_complexity
    init?(streamType: StreamType) {
        let value: TimeSeriesStreamType? = switch streamType {
        case .time,
                .distance,
                .lattitudeLongitude: nil
        case .watts: .watts
        case .cadence: .cadence
        case .heartrate: .heartrate
        case .altitude: .altitude
        case .smoothVelocity: .smoothVelocity
        case .torque: .torque
        case .temp: .temp
        case .leftRightBalance: .leftRightBalance
        case .leftPedalSmoothness: .leftPedalSmoothness
        case .rightPedalSmoothness: .rightPedalSmoothness
        case .leftTorqueEffectiveness: .leftTorqueEffectiveness
        case .rightTorqueEffectiveness: .rightTorqueEffectiveness
        case .coreTemperature: .coreTemperature
        case .skinTemperature: .skinTemperature
        case .verticalSpeed: .verticalSpeed
        }

        guard let value else { return nil }
        self = value
    }

    var asData: StreamType {
        switch self {
        case .watts: .watts
        case .cadence: .cadence
        case .heartrate: .heartrate
        case .altitude: .altitude
        case .smoothVelocity: .smoothVelocity
        case .torque: .torque
        case .temp: .temp
        case .leftRightBalance: .leftRightBalance
        case .leftPedalSmoothness: .leftPedalSmoothness
        case .rightPedalSmoothness: .rightPedalSmoothness
        case .leftTorqueEffectiveness: .leftTorqueEffectiveness
        case .rightTorqueEffectiveness: .rightTorqueEffectiveness
        case .coreTemperature: .coreTemperature
        case .skinTemperature: .skinTemperature
        case .verticalSpeed: .verticalSpeed
        }
    }

    var title: String {
        switch self {
        case .watts: "Power"
        case .cadence: "Cadence"
        case .heartrate: "Heart Rate"
        case .altitude: "Altitude"
        case .smoothVelocity: "Smooth Velocity"
        case .torque: "Torque"
        case .temp: "Outside Temperature"
        case .leftRightBalance: "L + R Balance"
        case .leftPedalSmoothness: "Left PS"
        case .rightPedalSmoothness: "Right PS"
        case .leftTorqueEffectiveness: "Left TE"
        case .rightTorqueEffectiveness: "Right TE"
        case .coreTemperature: "Core Temp"
        case .skinTemperature: "Skin Temp"
        case .verticalSpeed: "Vertical Speed"
        }
    }

    var defaultPlottable: Bool {
        switch self {
        case .smoothVelocity,
                .temp,
                .leftRightBalance,
                .leftPedalSmoothness,
                .rightPedalSmoothness,
                .leftTorqueEffectiveness,
                .rightTorqueEffectiveness,
                .torque,
                .skinTemperature,
                .verticalSpeed: false
        case .watts,
                .cadence,
                .heartrate,
                .altitude,
                .coreTemperature: true
        }
    }

    var removesZerosComputingAverage: Bool {
        self == .altitude || self == .cadence || self == .coreTemperature
    }

    func measurementType(for value: Double) -> TimeSeriesStreamTypeMeasurement? {
        let measurement: Measurement<Dimension>? = switch self {
        case .watts: Measurement(value: value, unit: UnitPower.watts)
        case .cadence: Measurement(value: value, unit: UnitFrequency.rotationsPerMinute)
        case .heartrate: Measurement(value: value, unit: UnitFrequency.heartBeatsPerMinute)
        case .altitude: Measurement(value: value, unit: UnitLength.meters)
        case .smoothVelocity,
                .verticalSpeed: Measurement(value: value, unit: UnitSpeed.metersPerSecond)
                .converted(to: UnitSpeed.kilometersPerHour)
        case .torque: Measurement(value: value, unit: UnitTorque.newtonMeter)
        case .temp, .coreTemperature, .skinTemperature: Measurement(value: value, unit: UnitTemperature.celsius)
        default: nil
        }

        guard let measurement else { return nil }

        return TimeSeriesStreamTypeMeasurement(measurement: measurement)
    }

    var color: Color {
        return switch self {
        case .watts: .blue
        case .cadence: .purple
        case .heartrate: .red
        case .altitude: .gray
        case .smoothVelocity: .yellow
        case .verticalSpeed: .yellow
        case .torque: .green
        case .temp: .cyan
        case .leftRightBalance: .brown
        case .leftPedalSmoothness: .green
        case .rightPedalSmoothness: .blue
        case .leftTorqueEffectiveness: .green
        case .rightTorqueEffectiveness: .blue
        case .coreTemperature: .green
        case .skinTemperature: .mint
        }
    }

    var isAreaChart: Bool {
        return switch self {
        case .watts,
        .cadence,
        .verticalSpeed,
        .torque: false
        case .smoothVelocity,
        .heartrate,
        .altitude,
        .temp,
        .leftRightBalance,
        .leftPedalSmoothness,
        .rightPedalSmoothness,
        .leftTorqueEffectiveness,
        .rightTorqueEffectiveness,
        .coreTemperature,
        .skinTemperature: true
        }
    }
}

struct TimeSeriesStreamTypeMeasurement {
    let measurement: Measurement<Dimension>
    let format: Measurement<Dimension>.FormatStyle = Measurement<Dimension>.FormatStyle(
        width: .narrow,
        usage: .asProvided,
        numberFormatStyle: .number.precision(.fractionLength(1))
    )
}
