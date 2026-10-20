//
//  ActivityStreamRepository.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import Foundation
import GRDB
import Combine

final class ActivityStreamRepository: Sendable {

    private let networkManager: NetworkManager
    private let streamDao: StreamDao

    init(
        networkManager: NetworkManager,
        streamDao: StreamDao
    ) {
        self.networkManager = networkManager
        self.streamDao = streamDao
    }

    func observeAllowedStreams(for activityId: Activity.ActivityId) -> AnyPublisher<[StreamType], Error> {
        streamDao.getStreamTypes(for: activityId)
            .map { $0.compactMap { StreamType(rawValue: $0.streamTypeId) } }
            .eraseToAnyPublisher()
    }

    func getSummaries(
        for activityId: Activity.ActivityId,
        filteringBy types: [StreamType],
        overTimeRange timeRange: Range<Int>? = nil,
    ) -> AnyPublisher<[StreamSummary], Error> {
        streamDao.observeSummaries(for: activityId, filteringBy: types, overTimeRange: timeRange)
    }

    func getStreams(
        for activityId: Activity.ActivityId,
        filteringBy types: [StreamType]
    ) -> AnyPublisher<[StreamType: [StreamPoint]], Error> {
        streamDao.observeStreams(for: activityId, filteringBy: types)
    }

    func getStreams(_ types: [StreamType], for activityId: Activity.ActivityId) async throws {
        let streamsForActivity: [StreamDto] = try await networkManager.get(
            streams: types.map { $0.asDto },
            forId: activityId
        )

        let streams: [Stream] = streamsForActivity.flatMap { dto in
            guard let type = StreamTypeDto(rawValue: dto.type)?.asDataStreamType,
                  type != .time || type != .lattitudeLongitude else {
                return [Stream]()
            }
            return dto.timeSeries?.enumerated().map { index, value in
                Stream(
                    id: "\(activityId)_\(type.rawValue)_\(index)",
                    type: type,
                    value: value ?? .zero,
                    order: index,
                    activityId: activityId,
                )
            } ?? []
        }

        await streamDao.store(streams: streams)
    }

}
