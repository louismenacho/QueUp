//
//  HomeViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation
import FirebaseAuth

class HomeViewModel {
    
    func signIn(as displayName: String) async throws -> User {
        try await AuthService.shared.signIn(with: displayName)
    }
    
    func createUser(_ user: User) throws {
        try UsersRepository.shared.create(id: user.id, user)
    }
}
