//
//  APIResponse.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 10/02/25.
//

import Foundation

// MARK: - Marvel Response
struct MarvelResponse<T: Decodable>: Decodable {
    let data: MarvelData<T>
}

struct MarvelData<T: Decodable>: Decodable {
    let results: [T]
}
