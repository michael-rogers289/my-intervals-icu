//
//  StreamTypeDto.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/2/26.
//

import Foundation

enum StreamTypeDto: String, Codable {
    case time
    case watts
    case cadence
    case heartrate
    case distance
    case altitude
    case lattitudeLongitude = "latlng"
    case velocitySmooth = "velocity_smooth"
    case torque
    case temp
    case leftRightBalance = "left_right_balance"
    case leftPedalSmoothness = "left_pedal_smoothness"
    case rightPedalSmoothness = "right_pedal_smoothness"
    case leftTorqueEffectiveness = "left_torque_effectiveness"
    case rightTorqueEffectiveness = "right_torque_effectiveness"
    case coreTemperature = "core_temperature"
    case skinTemperature = "skin_temperature"
}
