//
//  Constants.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 10.04.2024.
//

import Foundation

enum Constants {
    static let accessKey = "wU1B98spbyKpUIAVRiMMEUujaKbh_XmP2v-gXcB_jW0"
    static let secretKey = "LqCN9rK4zrYwbRlA955jZaPBGeVy5WxMkXXCyoMuezk"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static let grandType: String = "authorization_code"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
}
