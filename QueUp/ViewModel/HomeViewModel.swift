//
//  HomeViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation
import Firebase

class HomeViewModel {
    
    func firebaseSignIn() async throws -> Firebase.User {
        try await AuthService.shared.signIn()
    }
    
    func createUser(_ user: Firebase.User, displayName: String) throws -> User {
        let user = User(id: user.uid, displayName: displayName)
        try UserRepository.shared.create(user, with: user.id)
        return user
    }
    
    func createRoom(host: User) async throws {
        var room = Room(id: host.id, code: randomString(of: 4))
        //TODO: - check here if exists, else regenerate
        room.members.append(host)
        try RoomRepository.shared.create(room, with: room.id)
    }
    
    func randomString(of length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let string = String(repeating: "_", count: length)
        return String( string.map { _ in letters.randomElement()! } )
    }
}
