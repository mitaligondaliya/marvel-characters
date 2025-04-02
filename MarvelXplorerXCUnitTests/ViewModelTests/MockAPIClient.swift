//
//  MockAPIClient.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 02/04/25.
//

import XCTest
import Combine
@testable import MarvelXplorer

// MARK: - Mock API Client

/// A mock implementation of `APIClient` for testing purposes.
 class MockAPIClient: APIClient {

    /// The default result returned by the mock client.
    var result: Result<MarvelResponse<MarvelCharacter>, APIError> = .failure(.invalidResponse)

    /// A custom request handler allowing dynamic responses for different endpoints.
    var requestHandler: ((APIEndpoint) throws -> Result<MarvelResponse<MarvelCharacter>, APIError>)?

    /// Simulates an API request and returns a pre-defined result.
    /// - Parameters:
    ///   - endpoint: The API endpoint being requested.
    ///   - responseType: The expected response type.
    /// - Returns: A publisher that emits a successful or failed result.
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) -> AnyPublisher<T, APIError> {
        let resultToReturn: Result<T, APIError>

        // Determine which result to return: custom handler or default result.
        if let handler = requestHandler {
            resultToReturn = (try? handler(endpoint)) as? Result<T, APIError> ?? .failure(.invalidResponse)
        } else {
            resultToReturn = result as? Result<T, APIError> ?? .failure(.invalidResponse)
        }

        // Return the result as a Combine publisher.
        return Future<T, APIError> { promise in
            switch resultToReturn {
            case .success(let response):
                promise(.success(response))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
 }
