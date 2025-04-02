//
//  NetworkManagerTests.swift
//  MarvelXplorerTests
//
//  Created by Mitali Gondaliya on 25/03/25.
//

import Testing
import Foundation
import Combine
@testable import MarvelXplorer

final class NetworkManagerTests {

    // MARK: - Properties

    /// Stores cancellable subscriptions for Combine.
    var cancellables: Set<AnyCancellable> = []

    /// Instance of `NetworkManager` using a mock URL session.
    var networkManager: NetworkManager!

    init() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]  // Force mock requests
        let session = URLSession(configuration: config)

        networkManager = NetworkManager(session: session) // Ensure mock session is used
    }

    deinit {
        cancellables.removeAll()
        MockURLProtocol.requestHandler = nil  // Reset request handler
    }

    /// Mock JSON response data for a successful request.
    private let mockResponseJSON = """
    {
        "data": {
            "results": [
                {
                    "id": 1,
                    "name": "Iron Man",
                    "description": "A billionaire inventor",
                    "thumbnail": { "path": "https://example.com/image", "extension": "jpg" }
                }
            ]
        }
    }
    """

    // MARK: - Helper Methods

    /// Mocks an API response with the given status code and optional JSON data.
    /// - Parameters:
    ///   - statusCode: The HTTP status code to return.
    ///   - jsonData: The optional JSON data to include in the response.
    func mockResponse(statusCode: Int, jsonData: Data? = nil) {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, jsonData ?? Data()) // Ensure non-optional Data
        }
    }

    // MARK: - Test Cases

    /// Tests a successful API request and response decoding.
    @Test func testAPIRequest_Success() async throws {
        // Mock API response with valid JSON
        mockResponse(statusCode: 200, jsonData: self.mockResponseJSON.data(using: .utf8) ?? Data())

        try await confirmation("API request should succeed") { fulfill in
            let response = try await withCheckedThrowingContinuation { continuation in
                networkManager.request(.characters, responseType: MarvelResponse<MarvelCharacter>.self)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)  // ✅ Ensure error is handled
                        }
                    }, receiveValue: { response in
                        continuation.resume(returning: response) // ✅ Resume with successful response
                    })
                    .store(in: &cancellables) // Store subscription
            }
            // ✅ Assert Mocked Response
            #expect(response.data.results.count >= 1, "Expected at least one character in response")
            #expect(response.data.results.first?.name == "Iron Man", "Expected first character to be Iron Man")

            fulfill() // ✅ Mark test as completed
        }
    }

    /// Tests an API call that returns invalid JSON, expecting a decoding error.
    @Test func testAPIRequest_FailsWithDecodingError() async throws {
        let invalidJSON = "Invalid JSON"

        // Mock an invalid JSON response
        mockResponse(statusCode: 200, jsonData: invalidJSON.data(using: .utf8) ?? Data())

        await confirmation("Decoding error should occur") { fulfill in
            await withCheckedContinuation { continuation in
                networkManager.request(.characters, responseType: MarvelResponse<MarvelCharacter>.self)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            if case APIError.decodingError(_) = error {
                                fulfill() // ✅ Test passes
                            } else {
                                Issue.record("Expected decoding error but got \(error)")
                            }
                        }
                        continuation.resume()
                    }, receiveValue: { _ in
                        Issue.record("Expected failure but got success")
                        continuation.resume()
                    })
                    .store(in: &cancellables)
            }
        }
    }

    /// Tests an API call that fails due to a network error.
    @Test func testAPIRequest_FailsWithNetworkError() async {
        // Set up MockURLProtocol to throw a network error
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        await confirmation("Fetch characters should fail due to network error") { fulfill in
            await withCheckedContinuation { continuation in
                networkManager.request(.characters, responseType: MarvelResponse<MarvelCharacter>.self)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            if case APIError.networkError(_) = error {
                                fulfill() // ✅ Test passes
                            } else {
                                Issue.record("Expected network error but got \(error)")
                            }
                        }
                        continuation.resume() // Ensure continuation resumes
                    }, receiveValue: { _ in
                        Issue.record("Expected failure but got success")
                        continuation.resume()
                    })
                    .store(in: &cancellables)
            }
        }
    }
}
