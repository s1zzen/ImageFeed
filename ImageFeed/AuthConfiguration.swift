//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 22.05.2024.
//

import Foundation
enum Constants {
    static let accessKey = "wU1B98spbyKpUIAVRiMMEUujaKbh_XmP2v-gXcB_jW0"
    static let secretKey = "LqCN9rK4zrYwbRlA955jZaPBGeVy5WxMkXXCyoMuezk"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static let grandType: String = "authorization_code"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!

    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashUrl = "https://unsplash.com/oauth/token"

    static let keyChainKey = "Auth token"
}

struct AuthConfiguration {
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURL: Constants.defaultBaseURL,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 getTokenUrl: Constants.unsplashUrl,
                                 keyChainKey: Constants.keyChainKey)
    }
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    let getTokenUrl: String
    let keyChainKey: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String, getTokenUrl: String, keyChainKey: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
        self.getTokenUrl = getTokenUrl
        self.keyChainKey = keyChainKey
    }
}
