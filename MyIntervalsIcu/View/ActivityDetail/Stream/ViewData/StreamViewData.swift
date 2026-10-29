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

        enum ColorType {
            case solid(Color)
            case gradient([Gradient.Stop])
        }

        let streamType: TimeSeriesStreamType
        let colorType: ColorType
        let plottableData: [Point]

        init(streamType: TimeSeriesStreamType, colorType: ColorType, plottableData: [Point]) {
            self.streamType = streamType
            self.colorType = colorType
            self.plottableData = plottableData
        }

        init(streamType: TimeSeriesStreamType, plottableData: [Point]) {
            self.streamType = streamType
            self.colorType = .solid(streamType.color)
            self.plottableData = plottableData
        }

        subscript<T>(dynamicMember dynamicMember: KeyPath<TimeSeriesStreamType, T>) -> T {
            streamType[keyPath: dynamicMember]
        }
    }

    let timeSeries: [TimeSeries]

}
