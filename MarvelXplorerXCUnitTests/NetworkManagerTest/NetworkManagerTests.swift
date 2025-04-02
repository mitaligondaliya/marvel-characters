//
//  NetworkManagerTests.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 02/04/25.
//

import XCTest
import Foundation
import Combine
@testable import MarvelXplorer

// MARK: - Network Manager Tests

/// Unit tests for the `NetworkManager` class.
class NetworkManagerTests: XCTestCase {

    // MARK: - Properties

    /// Stores cancellable subscriptions for Combine.
    var cancellables: Set<AnyCancellable> = []

    /// Instance of `NetworkManager` using a mock URL session.
    var networkManager: NetworkManager!

    // MARK: - Setup & Teardown

    /// Sets up the test environment before each test.
    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        networkManager = NetworkManager(session: session)
    }

    /// Cleans up after each test.
    override func tearDown() {
        cancellables.removeAll()
        MockURLProtocol.requestHandler = nil  // Reset request handler
        super.tearDown()
    }

    // MARK: - Helper Methods

    /// Mocks an API response with the given status code and optional JSON data.
    /// - Parameters:
    ///   - statusCode: The HTTP status code to return.
    ///   - jsonData: The optional JSON data to include in the response.
    private func mockResponse(statusCode: Int, jsonData: Data? = nil) {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, jsonData ?? Data()) // Ensure non-optional Data
        }
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

    // MARK: - Test Cases

    /// Tests a successful API request and response decoding.
    func testAPIRequest_Success() {
        mockResponse(statusCode: 200, jsonData: mockResponseJSON.data(using: .utf8)!)

        let expectation = expectation(description: "API request should succeed")

        networkManager.request(.characters, responseType: MarvelResponse<MarvelCharacter>.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but got failure: \(error)")
                }
            }, receiveValue: { response in
                XCTAssertEqual(response.data.results.first?.name, "Iron Man")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 5)
    }

    /// Tests an API call that returns invalid JSON, expecting a decoding error.
    func testAPIRequest_FailsWithDecodingError() {
        let invalidJSON = "Invalid JSON"

        mockResponse(statusCode: 200, jsonData: invalidJSON.data(using: .utf8) ?? Data())

        let expectation = expectation(description: "Decoding error should occur")

        networkManager.request(.characters, responseType: MarvelResponse<MarvelCharacter>.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    if case APIError.decodingError(_) = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected decoding error but got \(error)")
                    }
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but got success")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    /// Tests an API call that fails due to a network error.
    func testAPIRequest_FailsWithNetworkError() {
        let expectation = expectation(description: "Fetch characters should fail due to network error")

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        networkManager.request(.characters, responseType: MarvelResponse<MarvelCharacter>.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    if case APIError.networkError(_) = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected network error but got \(error)")
                    }
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but got success")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    /// Tests an API call that returns a 401 Unauthorized error.
    func testAPIRequest_FailsWithUnauthorized() {
        mockResponse(statusCode: 401, jsonData: nil)

        let expectation = expectation(description: "Fetch characters should fail with unauthorized error")

        networkManager.request(.characters, responseType: MarvelResponse<MarvelCharacter>.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    if case APIError.unauthorized = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected unauthorized error but got \(error)")
                    }
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but got success")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }

    /// Tests an API call that returns a 500 Internal Server Error.
    func testAPIRequest_FailsWithServerError() {
        mockResponse(statusCode: 500, jsonData: nil)

        let expectation = expectation(description: "Fetch characters should fail with server error")

        networkManager.request(.characters, responseType: MarvelResponse<MarvelCharacter>.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    if case APIError.serverError = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected server error but got \(error)")
                    }
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but got success")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 3)
    }
}
