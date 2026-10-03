//
//  StreamTypeDtoToStreamTypeMapper.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/2/26.
//

import Foundation

extension StreamTypeDto {
    
    func mapToStreamTypeLink(with activity: ActivityDto) -> StreamTypeLink {
        let dataStreamTypeId = asDataStreamType.id
        return StreamTypeLink(
            id: "\(activity.id)_\(dataStreamTypeId)",
            streamTypeId: dataStreamTypeId,
            activityId: activity.id
        )
    }
    
    private var asDataStreamType: StreamType {
        return switch self {
        case .altitude: .altitude
        case .cadence: .cadence
        case .distance: .distance
        case .heartrate: .heartrate
        case .lattitudeLongitude: .lattitudeLongitude
        case .time: .time
        case .torque: .torque
        case .velocitySmooth: .smoothVelocity
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
