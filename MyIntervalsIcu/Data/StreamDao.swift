//
//  StreamDao.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import Foundation
import Combine
import GRDB

class StreamDao {
    
    private let databaseQueue: DatabaseQueue
    
    init(databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
    }
    
    @DatabaseActor
    func store(streamTypeLinks: [StreamTypeLink]) async {
        try? await databaseQueue.write { database in
            try streamTypeLinks.insertAll(in: database)
        }
    }
    
    func getStreamTypes(for activityId: Activity.ActivityId) -> AnyPublisher<[StreamTypeLink], Error> {
        ValueObservation.tracking { database in
            try StreamTypeLink
                .filter { $0.activityId == activityId }
                .fetchAll(database)
        }
        .publisher(in: databaseQueue)
        .eraseToAnyPublisher()
    }
}
