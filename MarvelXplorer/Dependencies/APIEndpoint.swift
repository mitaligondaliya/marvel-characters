//
//  APIEndpoint.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

// MARK: - API Endpoint

/// Enum representing the available HTTP methods for API requests.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

/// Enum defining the various API endpoints used in the Marvel API.
enum APIEndpoint {
    case characters             // Fetches a list of Marvel characters
    case characterDetail(id: Int) // Fetches details for a specific character
    case comics(characterId: Int) // Fetches comics related to a specific character

    /// The relative path for the API endpoint.
    var path: String {
        switch self {
        case .characters:
            return "/v1/public/characters"
        case .characterDetail(let id):
            return "/v1/public/characters/\(id)"
        case .comics(let characterId):
            return "/v1/public/characters/\(characterId)/comics"
        }
    }

    /// The HTTP method used for the request. Default is GET.
    var method: HTTPMethod { .get }

    /// The headers included in the API request.
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    /// The query parameters required for authentication and request configuration.
    var queryParams: [String: String] {
        let timestamp = MarvelAPI.timestamp
        return [
            "apikey": MarvelAPI.publicKey,
            "ts": timestamp,
            "hash": MarvelAPI.generateHash(timestamp: timestamp)
        ]
    }

    /// Constructs the full URL for the API request, including query parameters.
    var url: URL? {
        var components = URLComponents(string: MarvelAPI.baseURL)
        components?.path = path
        components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url
    }
}
