//
//  RoomRepository.swift
//  QueUp
//
//  Created by Louis Menacho on 4/25/22.
//

import Foundation

class RoomRepository: FirestoreRepository<Room> {
    
    static let shared = RoomRepository(collectionPath: "rooms")
    
    private override init(collectionPath: String) {
        super.init(collectionPath: collectionPath)
    }
}
