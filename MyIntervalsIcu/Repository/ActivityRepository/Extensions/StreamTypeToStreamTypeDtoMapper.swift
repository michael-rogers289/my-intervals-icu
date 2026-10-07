//
//  StreamTypeToStreamTypeDtoMapper.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/5/26.
//

import Foundation

extension StreamType {
    
    var asDto: StreamTypeDto {
        return switch self {
        case .altitude: .altitude
        case .cadence: .cadence
        case .distance: .distance
        case .heartrate: .heartrate
        case .lattitudeLongitude: .lattitudeLongitude
        case .time: .time
        case .torque: .torque
        case .smoothVelocity: .velocitySmooth
        case .watts: .watts
        case .temp: .temp
        case .leftRightBalance: .leftRightBalance
        case .leftPedalSmoothness: .leftPedalSmoothness
        case .rightPedalSmoothness: .rightPedalSmoothness
        case .leftTorqueEffectiveness: .leftTorqueEffectiveness
        case .rightTorqueEffectiveness: .rightTorqueEffectiveness
        case .coreTemperature: .coreTemperature
        case .skinTemperature: .skinTemperature
        }
    }
    
}
