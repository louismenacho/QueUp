//
//  UserService.swift
//  QueUp
//
//  Created by Louis Menacho on 5/11/22.
//

import Foundation

class UserService {
    
    var userRepo: FirestoreRepository<User> = .init(collectionPath: "rooms/ROOM_ID/users")
    
    var currentUsers: [User] = []
    
    var usersListener: ((Result<[User], Error>) -> Void)?
    
    func setRepoPath(_ path: String) {
        stopListener()
        self.userRepo = .init(collectionPath: path)
    }
    
    func startListener() {
        guard userRepo.collectionListener == nil else { return }
        userRepo.addListener { result in
            self.usersListener?( Result {
                self.currentUsers = try result.get()
                return self.currentUsers
            })
        }
    }
    
    func stopListener() {
        userRepo.removeListener()
    }
    
    func reset() {
        currentUsers = []
        usersListener = nil
    }
    
    func getUsers() async throws -> [User] {
        try await userRepo.list()
    }
    
    func addUser(_ user: User) throws {
        try userRepo.create(id: user.id, with: user)
    }
    
//    func userIdToDisplayName(id: String) -> String {
//        return currentRoom.users[id]?.displayName ?? "Unknown user"
//    }
}
