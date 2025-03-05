//
//  Comics.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

struct Comics: Decodable, Hashable {
    let available: Int
    let collectionURI: String
    let items: [ComicItem]
    let returned: Int
}

struct ComicItem: Decodable, Hashable {
    let resourceURI: String
    let name: String
}
