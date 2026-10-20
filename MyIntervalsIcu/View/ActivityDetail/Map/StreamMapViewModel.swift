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

    // MARK: Private Variables

    @ObservationIgnored
    private let coordinateRepository = Container.shared.activityCoordinateRepository.resolve()

    @ObservationIgnored
    private let selectedActivityId = Container.shared.detailActivityIdSelector.resolve()

    @ObservationIgnored
    private var viewLogger = Container.shared.viewLogger.resolve()

    private var latLongCancellable: AnyCancellable?

    // MARK: Public Variables

    private(set) var mapMarks: [MKMapPoint] = []

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
            .sink { [weak self] in
                self?.viewLogger.logError(message: "error fetching lat long \($0)")
            } onReceieveValue: { [weak self] in
                self?.viewLogger.logDebug(message: "received lat long")

                self?.mapMarks = $0.compactMap {
                    guard let latitude = $0.latitude, let longitude = $0.longitude else {
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

}
