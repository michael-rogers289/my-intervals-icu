//
//  StreamMapViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import Combine
import FactoryKit
import MapKit
import SwiftUI

@Observable
@MainActor
final class StreamMapViewModel {

    struct ViewData {
        let lowerExcludedMapMarks: [MKMapPoint]
        let upperExcludedMapMarks: [MKMapPoint]
        let selectedMapMarks: [MKMapPoint]

        init(
            lowerExcludedMapMarks: [MKMapPoint] = [],
            upperExcludedMapMarks: [MKMapPoint] = [],
            selectedMapMarks: [MKMapPoint] = []
        ) {
            self.lowerExcludedMapMarks = lowerExcludedMapMarks
            self.upperExcludedMapMarks = upperExcludedMapMarks
            self.selectedMapMarks = selectedMapMarks
        }
    }

    // MARK: Private Variables

    private let coordinateRepository = Container.shared.activityCoordinateRepository.resolve()
    private let selectedActivityId = Container.shared.detailActivityIdSelector.resolve()
    private let viewLogger = Container.shared.viewLogger.resolve()
    private let selectionViewModel: SelectionViewModel = Container.shared.activityDetailViewModel.resolve()
    private var latLongCancellable: AnyCancellable?

    // MARK: Public Variables

    private(set) var viewData = ViewData()

    // MARK: Life Cycle

    init() {
        guard let selectedActivityId else { return }
        Task { [weak self] in
            do {
                try await self?.coordinateRepository.fetchCoordinates(for: selectedActivityId)
            } catch {
                self?.viewLogger.logError(message: "error fetching coordinates \(error)")
            }
        }

        latLongCancellable = coordinateRepository
            .observeCoordinates(for: selectedActivityId)
            .combineLatest(selectionViewModel.selectionRanges) { coordinates, selection -> ViewData in
                guard !coordinates.isEmpty else {
                    return ViewData()
                }

                let selectedRange = selection ?? 0.0..<1.0

                let upperIndex = Int(selectedRange.upperBound * Double(coordinates.count))
                let lowerIndex = Int(selectedRange.lowerBound * Double(coordinates.count))

                let fullMapSelection = coordinates[lowerIndex..<upperIndex].toMkMapPoint()
                let lowerExcluded = coordinates[0..<lowerIndex].toMkMapPoint()
                let upperExcluded = coordinates[upperIndex..<coordinates.count].toMkMapPoint()

                return ViewData(
                    lowerExcludedMapMarks: lowerExcluded,
                    upperExcludedMapMarks: upperExcluded,
                    selectedMapMarks: fullMapSelection
                )
            }
            .sink { [weak self] in
                self?.viewLogger.logError(message: "error fetching lat long \($0)")
            } onReceieveValue: { [weak self] in
                self?.viewLogger.logDebug(message: "received lat long")
                self?.viewData = $0
            }
    }

}

private extension RandomAccessCollection<ActivityCoordinate> {

    func toMkMapPoint() -> [MKMapPoint] {
        compactMap { coordinate -> MKMapPoint? in
            guard let latitude = coordinate.latitude, let longitude = coordinate.longitude else {
                return nil
            }
            return MKMapPoint(
                CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude
                )
            )
        }
    }

}
