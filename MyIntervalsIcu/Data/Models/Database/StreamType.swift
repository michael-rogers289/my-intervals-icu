//
//  StreamType.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/2/26.
//

import CodingKeysMacro
import Foundation
import GRDB

@CodingKeys(.all)
struct StreamTypeLink: TableRecord, PersistableRecord, FetchableRecord, Codable {
    let id: String
    let streamTypeId: String
    let activityId: String
    
    enum Columns {
        static let id = Column(CodingKeys.id.rawValue)
        static let activityId = Column(CodingKeys.activityId.rawValue)
        static let streamTypeId = Column(CodingKeys.streamTypeId.rawValue)
    }

}

enum StreamType: String, CaseIterable, Codable {
    case time
    case watts
    case cadence
    case heartrate
    case distance
    case altitude
    case lattitudeLongitude = "lattitude_longitude"
    case smoothVelocity = "smooth_velocity"
    case torque
    case temp
    case leftRightBalance = "left_right_balance"
    case leftPedalSmoothness = "left_pedal_smoothness"
    case rightPedalSmoothness = "right_pedal_smoothness"
    case leftTorqueEffectiveness = "left_torque_effectiveness"
    case rightTorqueEffectiveness = "right_torque_effectiveness"
    case coreTemperature = "core_temperature"
    case skinTemperature = "skin_temperature"
    
    var defaultPlottable: Bool {
        switch self {
        case .time,
                .lattitudeLongitude,
                .distance,
                .smoothVelocity,
                .temp,
                .leftRightBalance,
                .leftPedalSmoothness,
                .rightPedalSmoothness,
                .leftTorqueEffectiveness,
                .rightTorqueEffectiveness,
                .skinTemperature: false
        case .watts,
                .cadence,
                .heartrate,
                .altitude,
                .torque,
                .coreTemperature: true
        }
    }
}
