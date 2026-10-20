//
//  ActivityCoordinateRepository.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import Foundation
import Combine

final class ActivityCoordinateRepository {

    private let networkManager: NetworkManager
    private let activityCoordinateDao: ActivityCoordinateDao

    init(
        networkManager: NetworkManager,
        activityCoordinateDao: ActivityCoordinateDao
    ) {
        self.networkManager = networkManager
        self.activityCoordinateDao = activityCoordinateDao
    }

    func fetchCoordinates(for activityId: Activity.ActivityId) async throws {
        guard let stream = try await networkManager.getStreamCoordinates(for: activityId) else {
            return
        }
        let coordinates = stream.timeSeries?.enumerated().map { index, value in
            ActivityCoordinate(
                id: "\(activityId)_\(index)",
                activityId: activityId,
                latitude: value,
                longitude: stream.values?[index],
                order: index
            )
        }
        guard let coordinates else { return }
        try await activityCoordinateDao.storeCoordinates(coordinates)
    }

    func observeCoordinates(for activityId: Activity.ActivityId) -> AnyPublisher<[ActivityCoordinate], Error> {
        activityCoordinateDao.observeCoordinates(for: activityId)
    }
}
