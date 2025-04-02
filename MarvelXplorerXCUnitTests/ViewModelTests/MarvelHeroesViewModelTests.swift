//
//  MarvelHeroesViewModelTests.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 02/04/25.
//

import XCTest
import Combine
@testable import MarvelXplorer

// MARK: - MarvelHeroesViewModel Unit Tests

/// Unit tests for `MarvelHeroesViewModel`, verifying API interactions and state updates.
class MarvelHeroesViewModelTests: XCTestCase {

    // MARK: - Properties

    var viewModel: MarvelHeroesViewModel!
    var mockAPIClient: MockAPIClient!
    var cancellables: Set<AnyCancellable> = []

    // MARK: - Setup & Teardown

    /// Sets up the test environment before each test.
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        viewModel = MarvelHeroesViewModel(networkManager: mockAPIClient)
    }

    /// Cleans up after each test.
    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Mock Response Data

    /// A mock API response containing sample Marvel character data.
    private let mockResponseData = MarvelResponse(data: MarvelData(results: [
        MarvelCharacter(
            id: 102123, name: "A.I.M",
            description: "AIM is a terrorist organization bent on destroying the world.",
            thumbnail: Thumbnail(path: "", extension: ""), comics: nil
        )
    ]))

    // MARK: - Test Cases

    /// Tests if the `fetchCharacters()` method successfully loads characters.
    func testFetchCharacters_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Characters loaded successfully")
        mockAPIClient.result = .success(mockResponseData)

        // When
        viewModel.fetchCharacters()

        // Then: Observe character list updates
        viewModel.$characters
            .dropFirst()
            .sink { characters in
                XCTAssertEqual(characters.count, 1, "Expected one character in response")
                XCTAssertEqual(characters.first?.name, "A.I.M", "Character name should match")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    /// Tests how the `fetchCharacters()` method handles API failure.
    func testFetchCharacters_Failure() {
        // Given
        let expectation = XCTestExpectation(description: "API Failure handled properly")
        mockAPIClient.result = .failure(APIError.serverError(statusCode: 500, message: "Internal Server Error"))

        // When
        viewModel.fetchCharacters()

        // Then: Observe error message & characters list
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage, "Error message should be set")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.$characters
            .dropFirst()
            .sink { characters in
                XCTAssertTrue(characters.isEmpty, "Characters should be empty on failure")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    /// Tests if `isLoading` state is correctly updated during data fetching.
    func testFetchCharacters_LoadingState() {
        // Given
        let expectation = XCTestExpectation(description: "isLoading state changes correctly")
        mockAPIClient.result = .success(MarvelResponse(data: MarvelData(results: [])))

        // When
        viewModel.fetchCharacters()

        // Then: Observe `isLoading` state changes
        XCTAssertTrue(viewModel.isLoading, "isLoading should be true when fetching starts")

        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    XCTAssertFalse(isLoading, "isLoading should be false after fetch completion")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    /// Tests if a server error (500) is properly handled.
    func testFetchCharacters_APIError_ServerError() {
        // Given
        let expectation = XCTestExpectation(description: "Handles server error (500)")
        mockAPIClient.result = .failure(APIError.serverError(statusCode: 500, message: "Internal Server Error"))

        // When
        viewModel.fetchCharacters()

        // Then: Observe error message updates
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, "Server error (500): Internal Server Error")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    /// Tests that the API is called only once on the first fetch.
    func testFetchCharacters_FirstTime_ShouldCallAPI() {
        // Given
        let expectation = XCTestExpectation(description: "API should be called on first fetch")
        mockAPIClient.result = .success(mockResponseData)

        // When
        viewModel.fetchCharacters()

        // Then: Verify character array updates
        viewModel.$characters
            .dropFirst()
            .sink { characters in
                XCTAssertFalse(characters.isEmpty, "Characters should be loaded")
                XCTAssertTrue(self.viewModel.hasFetchedCharacters, "hasFetchedCharacters should be true after fetching")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    /// Tests that the API is not called again if data has already been fetched.
    func testFetchCharacters_ShouldNotCallAPIAgain() {
        // Given
        let expectation = XCTestExpectation(description: "API should not be called again")
        var apiCallCount = 0

        mockAPIClient.requestHandler = { _ in
            apiCallCount += 1
            return .success(self.mockResponseData)
        }

        // When
        viewModel.fetchCharacters() // First call
        viewModel.fetchCharacters() // Second call (should not trigger API)

        // Then: Verify API call count
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(apiCallCount, 1, "API should only be called once")
            XCTAssertTrue(self.viewModel.hasFetchedCharacters, "hasFetchedCharacters should be true after first fetch")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }
}
