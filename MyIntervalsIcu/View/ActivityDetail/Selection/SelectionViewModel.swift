//
//  SelectionViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/22/26.
//

import Combine

@MainActor
protocol SelectionViewModel: AnyObject {
    /**
     The second selected point in a range selection. This _may_ or _may not_ be the upper bound of the selection depending on
    where the user has swiped and should be checked against the second point to create a valid range.
     */
    var secondSelectionRangeAsPercent: Double? { get set }
    /**
     The first selected point in a range selection. This _may_ or _may not_ be the lower bound of the selection depending on
     where the user has swiped and should be checked against the second point to create a valid range.
     */
    var firstSelectionRangeAsPercent: Double? { get set }

    /// A validated range encompasing the first and second selections
    var selections: AnyPublisher<Range<Double>?, Error> { get }

    func resetSelectionRange()
}
