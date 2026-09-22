//
//  Zone.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/12/26.
//

import SqlDsl
import Foundation

protocol Zone : CodingKeyAccessible {
    var zone: Int { get }
    var secondsInZone: Int { get }
    var activityId: String { get }
}
