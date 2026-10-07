//
//  ActivityStreamRepository.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import Foundation
import Combine

class ActivityStreamRepository {
    
    private let networkManager: NetworkManager
    private let streamDao: StreamDao
    
    init(
        networkManager: NetworkManager,
        streamDao: StreamDao
    ) {
        self.networkManager = networkManager
        self.streamDao = streamDao
    }
    
    func getAllowedStreams(for activityId: Activity.ActivityId) -> AnyPublisher<[StreamType], Error> {
        streamDao.getStreamTypes(for: activityId)
            .map { links in
                print("MyIntervalsIcu/StreamViewModel.swift got new links")
                return links.compactMap { StreamType(rawValue: $0.streamTypeId) }
            }
            .eraseToAnyPublisher()
    }
    
    func getStreams(_ types: [StreamType], for activityId: Activity.ActivityId) async -> [Stream] {
        do {
            return try await networkManager.get(
                streams: types.map { $0.asDto },
                forId: activityId
            ).compactMap { dto in
                guard let type = StreamTypeDto(rawValue: dto.type)?.asDataStreamType else {
                    return nil
                }
               
                return Stream(
                    type: type,
                    timeSeries: dto.timeSeries?.map { $0 ?? .zero } ?? [],
                    secondaryValues: dto.values?.map { $0 ?? .zero } ?? [],
                    anomalies: dto.anomalies?.map { anomalyDto in
                        Stream.Anomaly(
                            startIndex: anomalyDto.startIndex,
                            endIndex: anomalyDto.endIndex,
                            value: anomalyDto.value,
                            valueEnd: anomalyDto.valueEnd
                        )
                    } ?? []
                )
            }
        } catch {
            print("Error getting streams: \(error)")
            return []
        }
    }
    
}
