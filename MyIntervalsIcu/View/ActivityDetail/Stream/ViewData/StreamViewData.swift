//
//  StreamViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import SwiftUI

struct StreamViewData {

    struct Point: Equatable, Hashable {
        // swiftlint:disable:next identifier_name
        let x: Double
        // swiftlint:disable:next identifier_name
        let y: Double
    }

    @dynamicMemberLookup
    struct TimeSeries {
        let streamType: TimeSeriesStreamType
        let plottableData: [Point]

        subscript<T>(dynamicMember dynamicMember: KeyPath<TimeSeriesStreamType, T>) -> T {
            streamType[keyPath: dynamicMember]
        }
    }

    let timeSeries: [TimeSeries]

}
