//
//  MockURLSession.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 02/04/25.
//

import Combine
import Foundation
@testable import MarvelXplorer

// MARK: - Mock URL Protocol

/// A custom `URLProtocol` subclass used to mock network requests for unit testing.
class MockURLProtocol: URLProtocol {

    /// A static closure that acts as a request handler, allowing test cases to specify responses.
    /// - The closure takes a `URLRequest` and returns an HTTP response and optional data.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    // MARK: - URLProtocol Overrides

    /// Determines whether this protocol can handle the given request.
    /// - Returns: `true` to indicate that all requests should be handled by this mock.
    override class func canInit(with request: URLRequest) -> Bool {
        print("MockURLProtocol is intercepting request: \(request.url?.absoluteString ?? "Unknown URL")")
        return true
    }

    /// Returns the canonical version of the given request.
    /// - This method is required for `URLProtocol` conformance but does not modify the request.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    /// Starts handling a request by invoking the predefined request handler.
    /// - If the handler is not set, the test will fail with a `fatalError`.
    /// - If the handler throws an error, the request fails with that error.
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        do {
            // Get the response and data from the request handler.
            let (response, data) = try handler(request)

            // Notify the client that the response has been received.
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            // Provide the mock data to the client.
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // If an error occurs, notify the client of the failure.
            client?.urlProtocol(self, didFailWithError: error)
        }

        // Indicate that loading is complete.
        client?.urlProtocolDidFinishLoading(self)
    }

    /// Stops loading the request.
    /// - This method is required for `URLProtocol` conformance but is not used in this mock.
    override func stopLoading() {
        print("MockURLProtocol: Request was canceled.")
    }
}
