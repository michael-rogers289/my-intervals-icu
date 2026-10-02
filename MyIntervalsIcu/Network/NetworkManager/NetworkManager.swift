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
    
    // MARK: Public Variables
    
    let calendarRepository: CalendarRepository
    
    // MARK: Private Variables
        
    private let networkSession: NetworkSession
    private let networkLogger: NetworkLogging
    
    // MARK: Init

init(
    networkLogger: NetworkLogging,
    networkSession: NetworkSession,
    calendarRepository: CalendarRepository,
) {
        self.networkLogger = networkLogger
        self.networkSession = networkSession
        self.calendarRepository = calendarRepository
    }
        
    // MARK: Public Methods
    
    func fetchAndDecode<T: Decodable & Sendable>(
        with request: URLRequest
    ) async throws(NetworkManager.NetworkError) -> T {
        do {
            let (data, response) = try await networkSession.data(for: request)
            guard
                let response = response as? HTTPURLResponse,
                NetworkManager.HTTPStatus(rawValue: response.statusCode)?.isSuccess == true
            else {
                throw networkLogger.logError(
                    NetworkManager.NetworkError.unableToFetchData(forPath: response.url?.path ?? response.description),
                    for: request,
                    and: response
                )
            }
            
            let decoded: T = try await decode(type: T.self, from: data)
            
            networkLogger.logResponse(response, andData: decoded, of: request)

            return decoded
        } catch let decodingError as DecodingError {
            throw networkLogger.logError(
                NetworkManager.NetworkError.unableToDecodeResponse(decodeError: decodingError),
                for: request,
                and: nil
            )
        } catch let cancelationError as CancellationError {
            throw networkLogger.logError(
                NetworkManager.NetworkError.cancelled(error: cancelationError),
                for: request,
                and: nil
            )
        } catch {
            throw networkLogger.logError(
                NetworkManager.NetworkError.unableToFetchData(forPath: request.url?.path ?? request.description),
                for: request,
                and: nil
            )
        }
    }
    
    @concurrent
    private func decode<T: Decodable>(type: T.Type, from data: Data) async throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
}
