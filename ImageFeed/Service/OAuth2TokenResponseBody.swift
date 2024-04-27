//
//  ResponseBodyStructure.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 12.04.2024.
//

import Foundation

struct OAuth2TokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
