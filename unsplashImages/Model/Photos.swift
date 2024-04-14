//
//  Photos.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 13/04/24.
//

import Foundation

struct Photo: Codable {
    let id: String
    let urls: [String: String]
}
