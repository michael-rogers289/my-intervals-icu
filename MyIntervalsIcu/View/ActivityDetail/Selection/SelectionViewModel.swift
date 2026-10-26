//
//  SelectionViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/22/26.
//

import Combine

@MainActor
protocol SelectionViewModel: AnyObject {
    var upperSelectionRangeAsPercent: Double? { get set }
    var lowerSelectionRangeAsPercent: Double? { get set }
    var selections: AnyPublisher<Range<Double>?, Error> { get }

    func resetSelectionRange()
}
