//
//  StreamViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import SwiftUI

struct StreamViewData {
    
    struct Point : Equatable, Hashable {
        let yValueTitle: String
        
        let x: Double
        let y: Double
    }
    
    struct TimeSeries {
        let streamType: TimeSeriesStreamType
        let plottableData: [Point]
        let minY: Double
        let maxY: Double
        
        func copy(updatedPoints plottableData: [Point]) -> TimeSeries {
            TimeSeries(
                streamType: streamType,
                plottableData: plottableData,
                minY: minY,
                maxY: maxY
            )
        }
    }
    
    enum TimeSeriesStreamType : CaseIterable {
        case watts
        case cadence
        case heartrate
        case altitude
        case smoothVelocity
        case torque
        case temp
        case leftRightBalance
        case leftPedalSmoothness
        case rightPedalSmoothness
        case leftTorqueEffectiveness
        case rightTorqueEffectiveness
        case coreTemperature
        case skinTemperature
        
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
            }
            
            guard let value else { return nil }
            self = value
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
                    .skinTemperature: false
            case .watts,
                    .cadence,
                    .heartrate,
                    .altitude,
                    .coreTemperature: true
            }
        }
        
        var color: Color {
            return switch self {
            case .watts: .blue
            case .cadence: .purple
            case .heartrate: .red
            case .altitude: .gray
            case .smoothVelocity: .yellow
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
    }
    
    let timeSeries: [TimeSeries]
    let areaTimeSeries: TimeSeries?
    let xMax: Double
    
}
