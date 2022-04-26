//
//  SessionService.swift
//  QueUp
//
//  Created by Louis Menacho on 4/25/22.
//

import Foundation
import FirebaseAuth

class SessionService {
    
    static let shared = SessionService()
    
    let userRepo = UserRepository.shared
    let roomRepo = RoomRepository.shared
    
    private init() {}
    
    func signIn(with displayName: String) async throws -> User {
        let firebaseUser = try await AuthService.shared.signIn()
        let user = User(id: firebaseUser.uid, displayName: displayName)
        try userRepo.create(user, with: user.id)
        return user
    }
    
    func join(user: User, to roomId: String) async throws {
        guard var room = try await roomRepo.get(id: roomId) else {
            print("Room does not exist")
            return
        }
        guard room.users.count == 8 else {
            print("Room is full")
            return
        }
        room.users[user.id] = user
        try roomRepo.update(room, with: room.id)
    }
    
    func createRoom(host: User) async throws {
        var room = Room(id: randomString(of: 4), hostId: host.id)
        //TODO: - check here if exists, else regenerate
        room.users[host.id] = host
        try roomRepo.create(room, with: room.id)
    }
    
    func randomString(of length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let string = String(repeating: "_", count: length)
        return String(string.map { _ in letters.randomElement()! })
    }
    
}
