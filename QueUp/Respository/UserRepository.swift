//
//  UserRepository.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation

class UserRepository: FirestoreRepository<User> {
    
    static let shared = UserRepository(collectionPath: "users")
    
    private override init(collectionPath: String) {
        super.init(collectionPath: collectionPath)
    }
}
