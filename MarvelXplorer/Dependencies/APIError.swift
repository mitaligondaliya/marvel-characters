//
//  APIError.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case serverError(statusCode: Int)
    case networkError(URLError)
    case decodingError
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .serverError(let statusCode):
            return "Server returned an error with status code \(statusCode)."
        case .networkError(let urlError):
            return "Network error: \(urlError.localizedDescription)"
        case .decodingError:
            return "Failed to decode the response."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
