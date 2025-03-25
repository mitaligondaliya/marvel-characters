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
    /// The requested URL is invalid.
    case invalidURL
    
    /// The server returned no content (HTTP 204).
    case noContent
    
    /// The server response was invalid or unexpected.
    case invalidResponse
    
    /// The request was unauthorized (HTTP 401).
    case unauthorized
    
    /// A network-related error occurred.
    /// - Parameter urlError: The underlying `URLError` that caused the failure.
    case networkError(URLError)
    
    /// A server error occurred with a specific status code.
    /// - Parameters:
    ///   - statusCode: The HTTP status code received from the server.
    ///   - message: An optional message describing the server error.
    case serverError(statusCode: Int, message: String?)
    
    /// The response data could not be decoded correctly.
    /// - Parameter description: A message describing the decoding failure.
    case decodingError(description: String)
    
    /// The request timed out due to network issues.
    case timeout
    
    /// An unknown error occurred.
    /// - Parameter error: An optional underlying error.
    case unknownError(Error?)

    /// Compares two `APIError` instances for equality.
    /// - Parameters:
    ///   - lhs: The first `APIError` to compare.
    ///   - rhs: The second `APIError` to compare.
    /// - Returns: `true` if the errors are equivalent, otherwise `false`.
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
