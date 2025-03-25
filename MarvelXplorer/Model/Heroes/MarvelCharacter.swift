//
//  MarvelCharacter.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

// MARK: - Marvel Character Model

/// Represents a Marvel character with an ID, name, description, thumbnail, and comics.
struct MarvelCharacter: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: Thumbnail
    let comics: Comics?
}

// MARK: - Thumbnail Model

/// Stores the thumbnail image details for a Marvel character.
struct Thumbnail: Codable, Equatable, Hashable {
    let path: String
    let `extension`: String

    /// Generates a full URL for the thumbnail image.
    var url: URL? {
        return URL(string: "\(path).\(`extension`)")
    }
}

// MARK: - MarvelCharacter Extensions

extension MarvelCharacter: Equatable {
    /// Checks equality between two MarvelCharacter instances.
    static func == (lhs: MarvelCharacter, rhs: MarvelCharacter) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.thumbnail == rhs.thumbnail
    }

    /// Example Marvel character for previews or testing.
    public static var example: MarvelCharacter {
        MarvelCharacter(
            id: 102123, name: "A.I.M",
            description: "AIM is a terrorist organization bent on destroying the world.",
            thumbnail: Thumbnail(path: "", extension: ""), comics: nil
        )
    }
}
