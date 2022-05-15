//
//  UserService.swift
//  QueUp
//
//  Created by Louis Menacho on 5/11/22.
//

import Foundation

class UserService {
    
    static let shared = UserService()
    
    var repo: FirestoreRepository<User> = .init(collectionPath: "rooms/ROOM_ID/users")
    
    var listener: ((Result<[User], Error>) -> Void)?
    
    private init() {}
    
    func set(roomId: String) {
        repo = .init(collectionPath: "rooms/"+roomId+"/users")
    }
    
    func startListener() {
        guard repo.collectionListener == nil else { return }
        repo.addListener { result in
            self.listener?(result)
        }
    }
    
    func stopListener() {
        repo.removeListener()
        listener = nil
    }
    
    func getUser(id: String) async throws -> User {
        return try await repo.get(id: id)
    }
    
    func listUsers() async throws -> [User] {
        return try await repo.list()
    }
    
    func addUser(_ user: User) async throws {
        try repo.create(id: user.id, with: user)
    }
    
    func removeUser(_ user: User) async throws {
        try await repo.delete(id: user.id)
    }
    
    func removeAllUsers() async throws {
        try await repo.deleteAll()
    }
}
