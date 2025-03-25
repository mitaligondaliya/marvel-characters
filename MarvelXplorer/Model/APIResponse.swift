//
//  APIResponse.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

// MARK: - Marvel API Response Models

/// A generic response wrapper for Marvel API responses.
struct MarvelResponse<T: Decodable>: Decodable {
    /// Contains the main data payload from the API response.
    let data: MarvelData<T>
}

// MARK: - Marvel Data Container

/// A container for the actual results returned by the Marvel API.
struct MarvelData<T: Decodable>: Decodable {
    /// The list of results (e.g., characters, comics) from the API response.
    let results: [T]
}
