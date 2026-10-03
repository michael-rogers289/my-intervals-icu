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
    let streamTypeId: Int
    let activityId: String
    
    enum Columns {
        static let id = Column(CodingKeys.id.rawValue)
        static let activityId = Column(CodingKeys.activityId.rawValue)
        static let streamTypeId = Column(CodingKeys.streamTypeId.rawValue)
    }

}

struct StreamTypeRecord: TableRecord, PersistableRecord, FetchableRecord, Codable {
    let id: Int
    let name: StreamType
    
    enum Columns {
        static let id = Column("id")
        static let name = Column("name")
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

    
    var id : Int {
        switch self {
        case .time: 1
        case .watts: 2
        case .cadence: 3
        case .heartrate: 4
        case .distance: 5
        case .altitude: 6
        case .lattitudeLongitude: 7
        case .smoothVelocity: 8
        case .torque: 9
        case .temp: 10
        case .leftRightBalance: 11
        case .leftPedalSmoothness: 12
        case .rightPedalSmoothness: 13
        case .leftTorqueEffectiveness: 14
        case .rightTorqueEffectiveness: 15
        case .coreTemperature: 16
        case .skinTemperature: 17
        }
    }
}
