//
//  ConfigRepository.swift
//  QueUp
//
//  Created by Louis Menacho on 4/29/22.
//

import Foundation

class ConfigRepository: FirestoreRepository<Room> {
    
    static let shared = ConfigRepository(collectionPath: "configs")
    
    private override init(collectionPath: String) {
        super.init(collectionPath: collectionPath)
    }
}
