//
//  NetworkManager.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/8/25.
//

import Foundation
import Blade

actor NetworkManager {
    
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
        
    private let networkConstants = NetworkConstants()
    private let standardFormatter = StandardFormatter()

    init() { }
        
    private func makeRequest(
        appendingPath pathToAppend: String? = nil,
        addingQueryParameters queryParameters: [URLQueryItem] = [],
        shouldAppendAthleteId: Bool = true
    ) -> URLRequest {
        let baseUrl = if (shouldAppendAthleteId) {
            networkConstants.baseUrl.appending(path: networkConstants.athleteId)
        } else {
            networkConstants.baseUrl
        }
        
        var url = if let pathToAppend {
            baseUrl.appendingPathComponent(pathToAppend)
        } else {
            baseUrl
        }
        
        url.append(queryItems: queryParameters)
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(networkConstants.authHeaderValue, forHTTPHeaderField: "Authorization")
        return request
    }

    func getActivities(for dateRange: DateInterval) async throws(NetworkError) -> [ActivityDto] {
        let oldestQueryItem = URLQueryItem(
            name: Constant.oldestActivityQueryKey,
            value: standardFormatter.format(dateRange.start)
        )
        let newestQueryItem = URLQueryItem(
            name: Constant.newestActivityQueryKey,
            value: standardFormatter.format(dateRange.end)
        )
        let request = makeRequest(appendingPath: "activities", addingQueryParameters: [oldestQueryItem, newestQueryItem])
        return try await URLSession.shared.fetchAndDecode(with: request)
    }
}

private extension URLSession {
    
    @concurrent
    func fetchAndDecode<T: Decodable>(
        with request: URLRequest
    ) async throws(NetworkManager.NetworkError) -> T {
        do {
            let (data, response) = try await self.data(for: request)
            guard
                let response = response as? HTTPURLResponse,
                NetworkManager.HTTPStatus(rawValue: response.statusCode)?.isSuccess == true
            else {
                throw NetworkManager.NetworkError.unableToFetchData(forPath: response.url?.path ?? response.description)
            }
            return try await decode(type: T.self, from: data)
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
