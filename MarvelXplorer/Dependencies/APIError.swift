//
//  APIError.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

// MARK: - API Error Wrapper

/// Represents possible errors that can occur during network requests.
enum APIError: Error, LocalizedError, Equatable {
    case invalidURL
    case noContent
    case invalidResponse
    case unauthorized
    case networkError(URLError)
    case serverError(statusCode: Int, message: String?)
    case decodingError(description: String)
    case timeout
    case unknownError(Error?)

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.noContent, .noContent):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.unauthorized, .unauthorized):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.code == rhsError.code
        case (.serverError(let lhsCode, let lhsMessage), .serverError(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage
        case (.decodingError(let lhsDesc), .decodingError(let rhsDesc)):
            return lhsDesc == rhsDesc
        case (.timeout, .timeout):
            return true
        case (.unknownError, .unknownError):
            return true
        default:
            return false
        }
    }

    /// Provides a user-friendly description of the error.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .noContent:
            return "Received an empty data from the server."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .unauthorized:
            return "Unauthorized access. Please check your API key or authentication."
        case .networkError(let urlError):
            return "\(urlError.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "No error message provided.")"
        case .decodingError(let description):
            return "Decoding error: \(description)"
        case .timeout:
            return "The request timed out. Please check your internet connection."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
