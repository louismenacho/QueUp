//
//  PlaylistRepository.swift
//  QueUp
//
//  Created by Louis Menacho on 5/8/22.
//

import Foundation

class PlaylistRepository: FirestoreRepository<PlaylistItem> {
    
    static let shared = PlaylistRepository(
        collectionPath: "rooms/"+SessionService.shared.currentRoom.id+"/playlist"
    )
    
    private override init(collectionPath: String) {
        super.init(collectionPath: collectionPath)
    }
}
