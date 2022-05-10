//
//  PlaylistRepository.swift
//  QueUp
//
//  Created by Louis Menacho on 5/8/22.
//

import Foundation

class PlaylistRepository: FirestoreRepository<Playlist> {
    
    static let shared = PlaylistRepository(collectionPath: "playlists")
    
    private override init(collectionPath: String) {
        super.init(collectionPath: collectionPath)
    }
}
