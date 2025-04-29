//
//  Constants.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 11/02/25.
//

import Foundation

// MARK: - Marvel API

/// A struct responsible for managing API-related constants and generating authentication parameters for Marvel's API.
struct MarvelAPI {

    /// The timestamp used for API requests, generated dynamically based on the current time.
    static let timestamp = "\(Date().timeIntervalSince1970)"

    /// The base URL for the Marvel API.
    static let baseURL = "https://gateway.marvel.com"

    /// Generates an MD5 hash required for Marvel API authentication.
    /// - Parameter timestamp: A unique timestamp value used in the hash generation.
    /// - Returns: A hashed string combining the timestamp, private key, and public key.
    static func generateHash(timestamp: String) -> String {
        let input = timestamp + Secrets.privateKey + Secrets.publicKey
        return input.md5()
    }
}
