//
//  String+MD5.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 11/02/25.
//

import Foundation
import CryptoKit

extension String {
    func md5() -> String {
        let data = Data(self.utf8)
        return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
    }
}
