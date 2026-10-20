//
//  ActivityCoordinateDao.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import Combine
import Foundation
import GRDB

final class ActivityCoordinateDao {

    private let databaseQueue: DatabaseQueue

    init(databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
    }

    func storeCoordinates(_ activityCoordinates: [ActivityCoordinate]) async throws {
        try await databaseQueue.write { database in
            try activityCoordinates.insertAll(in: database)
        }
    }

    func observeCoordinates(
        for activityId: Activity.ActivityId,
    ) -> AnyPublisher<[ActivityCoordinate], Error> {
        ValueObservation.tracking { database in
            try ActivityCoordinate
                .filter { $0.activityId == activityId }
                .order { $0.order.asc }
                .fetchAll(database)
        }
        .publisher(in: databaseQueue)
        .eraseToAnyPublisher()
    }

}
