//
//  AuthService.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation
import Firebase

class AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    func signIn() async throws -> Firebase.User {
        let authData = try await Auth.auth().signInAnonymously()
        return authData.user
    }
}
