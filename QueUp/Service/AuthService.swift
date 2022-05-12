//
//  AuthService.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    static let shared = AuthService()
    
    var signedInUser = User()
    
    private init() {}
    
    func signIn(with displayName: String) async throws -> User {
        let authData = try await Auth.auth().signInAnonymously()
        let user = User(id: authData.user.uid, displayName: displayName)
        signedInUser = user
        return user
    }
}
