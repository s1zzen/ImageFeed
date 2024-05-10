//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 12.04.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2AccessToken"
    private let storage = KeychainWrapper.standard
    
    var token: String? {
        get {
            return storage.string(forKey: tokenKey)
        }
        set {
            guard let newValue = newValue else { 
                assertionFailure("[OAuth2TokenStorage]: newValue Error")
                return }
            let isSuccess = storage.set(newValue, forKey: tokenKey)
            guard isSuccess else {
                assertionFailure("[OAuth2TokenStorage]: Save Error - SwiftKeychainWrapper Error")
                return
            }
        }
    }
    
    func logout() {
        storage.removeObject(forKey: tokenKey)
    }
    
    private init() {}
    
    static let shared = OAuth2TokenStorage()
}
