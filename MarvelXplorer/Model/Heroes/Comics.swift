//
//  Comics.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

// MARK: - Comics Model

/// Represents the comics associated with a Marvel character.
struct Comics: Codable, Hashable {
    let available: Int
    let collectionURI: String
    let items: [ComicItem]
    let returned: Int
}

// MARK: - Comic Item Model

/// Represents a single comic item in the comics list.
struct ComicItem: Codable, Hashable {
    let resourceURI: String
    let name: String
}
