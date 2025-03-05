//
//  APIEndpoint.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
}

struct Endpoint {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let body: Data?

    init(
        baseURL: URL,
        path: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = [],
        body: Data? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    var url: URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.path += path
        components?.queryItems = queryItems
        return components?.url
    }
}

extension Endpoint {
    // Helper Function to Create Endpoint
    private static func makeEndpoint(
        path: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        additionalQueryItems: [URLQueryItem] = [],
        body: Data? = nil
    ) -> Endpoint {
        let timestamp = "\(Date().timeIntervalSince1970)"
        let hash = (timestamp + privateKey + publicKey).md5()

        var queryItems = [
            URLQueryItem(name: "apikey", value: publicKey),
            URLQueryItem(name: "ts", value: timestamp),
            URLQueryItem(name: "hash", value: hash)
        ]
        queryItems.append(contentsOf: additionalQueryItems)

        return Endpoint(
            baseURL: apiURL,
            path: path,
            method: method,
            headers: headers,
            queryItems: queryItems,
            body: body
        )
    }

    // Public Endpoints
    static func characters() -> Endpoint {
        return makeEndpoint(
            path: "/characters"
        )
    }

    static func characterDetail(characterID: Int) -> Endpoint {
        return makeEndpoint(path: "/characters/\(characterID)")
    }
}
