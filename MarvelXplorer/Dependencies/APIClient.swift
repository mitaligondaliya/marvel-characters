//
//  APIClient.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation
import Combine

protocol APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> AnyPublisher<T, APIError>
}

class NetworkManager: APIClient {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> AnyPublisher<T, APIError> {
        guard let url = endpoint.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(for: endpoint, url: url)

        return session.dataTaskPublisher(for: request)
            .tryMap { response in
                try self.handleResponse(response)
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                self.mapError(error)
            }
            .eraseToAnyPublisher()
    }

    // Helper method to create a URLRequest
    private func createRequest(for endpoint: Endpoint, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        for (headerField, headerValue) in endpoint.headers {
            request.setValue(headerValue, forHTTPHeaderField: headerField)
        }
        request.httpBody = endpoint.body
        return request
    }

    // Helper method to handle the response
    private func handleResponse(_ response: URLSession.DataTaskPublisher.Output) throws -> Data {
        if let httpResponse = response.response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        return response.data
    }

    // Map errors to custom APIError type
    private func mapError(_ error: Error) -> APIError {
        if let urlError = error as? URLError {
            return APIError.networkError(urlError)
        } else if error is DecodingError {
            return APIError.decodingError
        } else if let apiError = error as? APIError {
            return apiError
        } else {
            return APIError.unknownError
        }
    }
}
