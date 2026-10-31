//
//  ComparableExtensions.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/30/26.
//

import Foundation

extension Comparable {

    func clamped(to range: Range<Self>) -> Self {
        return max(range.lowerBound, min(range.upperBound, self))
    }

}
