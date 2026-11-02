//
//  ActivityStreamSummary.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/1/26.
//

import Foundation

struct ActivityStreamSummary {

    let activityFtpSummary: ActivityFtpSummary
    let streams: [StreamType: [StreamPoint]]

}
