//
//  UsersRepository.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation

class UsersRepository: FirestoreRepository<User> {
    
    static let shared = UsersRepository(collectionPath: "users")
    
    private override init(collectionPath: String) {
        super.init(collectionPath: collectionPath)
    }
}
