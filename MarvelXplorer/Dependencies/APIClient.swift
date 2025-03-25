//
//  APIClient.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation
import Combine
import os

// MARK: - Network Manager

/// Protocol defining the API client behavior for making network requests.
protocol APIClient {
    /// Makes a network request to the specified API endpoint and decodes the response into the given type.
    /// - Parameters:
    ///   - endpoint: The API endpoint to request.
    ///   - responseType: The expected response type to decode.
    /// - Returns: A publisher emitting the decoded response or an APIError.
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) -> AnyPublisher<T, APIError>
}

/// NetworkManager responsible for handling API requests and responses.
class NetworkManager: APIClient {

    private let session: URLSession

    /// Initializes the NetworkManager with a URLSession instance.
    /// - Parameter session: The URLSession instance, defaulting to shared session.
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// Executes a network request and decodes the response.
    /// - Parameters:
    ///   - endpoint: The API endpoint to request.
    ///   - responseType: The expected response type.
    /// - Returns: A publisher that emits the decoded response or an APIError.
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) -> AnyPublisher<T, APIError> {
        guard let url = endpoint.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(for: endpoint, url: url)

        logRequest(request)

        return session.dataTaskPublisher(for: request)
            .tryMap { output in
                self.logResponse(output.response, data: output.data)
                return try self.validateResponse(output)
            }
            .decode(type: T.self, decoder: jsonDecoder)
            .mapError { self.handleError($0) }
            .eraseToAnyPublisher()
    }

    /// Creates a URLRequest for the given endpoint and URL.
    /// - Parameters:
    ///   - endpoint: The API endpoint.
    ///   - url: The URL for the request.
    /// - Returns: A configured URLRequest.
    private func createRequest(for endpoint: APIEndpoint, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 20
        request.allHTTPHeaderFields = endpoint.headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    /// Validates the HTTP response and extracts the data if successful.
    /// - Parameter output: The output from the URLSession publisher.
    /// - Throws: An APIError if the response is invalid or contains an error status code.
    /// - Returns: The response data.
    private func validateResponse(_ output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let httpResponse = output.response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return output.data
        case 204:
            throw APIError.noContent
        case 401:
            throw APIError.unauthorized
        case 500...599:
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Internal Server Error")
        default:
            let errorMessage = String(data: output.data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
    }

    /// Handles and maps errors from network requests.
    /// - Parameter error: The encountered error.
    /// - Returns: A corresponding APIError.
    private func handleError(_ error: Error) -> APIError {
        switch error {
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet:
                return .networkError(urlError)
            case .timedOut:
                return .timeout
            default:
                return .networkError(urlError)
            }
        case let decodingError as DecodingError:
            return .decodingError(description: decodingError.localizedDescription)
        case let apiError as APIError:
            return apiError
        default:
            return .unknownError(error)
        }
    }

    /// Logs request details for debugging.
    /// - Parameter request: The URLRequest being logged.
    private func logRequest(_ request: URLRequest) {
        os_log(
            "📡 [Request] %@ %@",
            log: .default,
            type: .info, request.httpMethod ?? "",
            request.url?.absoluteString ?? ""
        )
    }

    /// Logs response details for debugging.
    /// - Parameters:
    ///   - response: The URLResponse received.
    ///   - data: The response data.
    private func logResponse(_ response: URLResponse, data: Data) {
        if let httpResponse = response as? HTTPURLResponse {
            os_log(
                "✅ [Response] Status Code: %d, %d bytes received",
                log: .default,
                type: .info,
                httpResponse.statusCode,
                data.count
            )
        }
    }
}
