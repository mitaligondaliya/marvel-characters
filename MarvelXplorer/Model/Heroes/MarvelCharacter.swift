//
//  MarvelCharacter.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

struct MarvelCharacter: Identifiable, Decodable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: Thumbnail
    let comics: Comics?
}

struct Thumbnail: Decodable {
    let path: String
    let `extension`: String

    var url: URL? {
        return URL(string: "\(path).\(`extension`)")
    }
}

extension MarvelCharacter {
    public static var example: MarvelCharacter {
        MarvelCharacter(
            id: 102123, name: "A.I.M",
            description: "AIM is a terrorist organization bent on destroying the world.",
            thumbnail: Thumbnail(path: "", extension: ""), comics: nil
        )
    }
}
