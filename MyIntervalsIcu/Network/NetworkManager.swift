//
//  NetworkManager.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/8/25.
//

import Foundation
import Blade

actor NetworkManager {
    
    // MARK: Enums
    
    enum NetworkError : Error {
        case unableToFetchData(forPath: String)
        case unableToDecodeResponse(decodeError: DecodingError)
        case cancelled(error: CancellationError)
    }
    
    enum HTTPStatus: Int {
        case ok = 200
        case created = 201
        case noContent = 204
        case badRequest = 400
        case unauthorized = 401
        case notFound = 404
        case internalServerError = 500
        
        var isSuccess: Bool {
            switch self {
            case .ok, .created, .noContent:
                return true
            default:
                return false
            }
        }
    }
    
    private enum Constant {
        static let oldestActivityQueryKey = "oldest"
        static let newestActivityQueryKey = "newest"
    }
    
    // MARK: Private Variables
        
    private let requestBuilder = NetworkRequestBuilder()
    private let standardFormatter = StandardFormatter()
    private let networkSession: NetworkSession
    private let networkLogger: NetworkLogging
    
    // MARK: Init

    init(
        networkLogger: NetworkLogging,
        networkSession: NetworkSession
    ) {
        self.networkLogger = networkLogger
        self.networkSession = networkSession
    }
        
    // MARK: Public Methods

    func getActivities(for dateRange: DateInterval) async throws(NetworkError) -> [ActivityDto] {
        let oldestQueryItem = URLQueryItem(
            name: Constant.oldestActivityQueryKey,
            value: standardFormatter.format(dateRange.start)
        )
        let newestQueryItem = URLQueryItem(
            name: Constant.newestActivityQueryKey,
            value: standardFormatter.format(dateRange.end)
        )
        let request = requestBuilder.makeAthleteRequest(appendingPath: "activities", addingQueryParameters: [oldestQueryItem, newestQueryItem])
        return try await fetchAndDecode(with: request)
    }
    
    func getHistogram(forActivityId activityId: String) async throws(NetworkError) -> [HistogramDto] {
        let request = requestBuilder.makeActivityRequest(activityId: activityId)
        return try await fetchAndDecode(with: request)
    }
    
    // MARK: Private Methods
    private func fetchAndDecode<T: Decodable & Sendable>(
        with request: URLRequest
    ) async throws(NetworkManager.NetworkError) -> T {
        do {
            let (data, response) = try await networkSession.data(for: request)
            guard
                let response = response as? HTTPURLResponse,
                NetworkManager.HTTPStatus(rawValue: response.statusCode)?.isSuccess == true
            else {
                throw NetworkManager.NetworkError.unableToFetchData(forPath: response.url?.path ?? response.description)
            }
            
            let decoded: T = try await decode(type: T.self, from: data)
            
            networkLogger.logResponse(response, andData: decoded, of: request)

            return decoded
        } catch let networkError as NetworkManager.NetworkError {
            throw networkError
        } catch let decodingError as DecodingError {
            throw NetworkManager.NetworkError.unableToDecodeResponse(decodeError: decodingError)
        } catch let cancelationError as CancellationError {
            throw NetworkManager.NetworkError.cancelled(error: cancelationError)
        } catch {
            throw NetworkManager.NetworkError.unableToFetchData(forPath: "activities")
        }
    }
    
    @concurrent
    private func decode<T: Decodable>(type: T.Type, from data: Data) async throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
}
