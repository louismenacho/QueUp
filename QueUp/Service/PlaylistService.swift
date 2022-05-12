//
//  PlaylistService.swift
//  QueUp
//
//  Created by Louis Menacho on 5/8/22.
//

import Foundation

class PlaylistService {
    
    static let shared = PlaylistService()

    var repo: FirestoreRepository<PlaylistItem> = .init(collectionPath: "rooms/ROOM_ID/playlist")
    
    var listener: ((Result<[PlaylistItem], Error>) -> Void)?
    
    private init() {}
    
    func set(roomId: String) {
        repo = .init(collectionPath: "rooms/"+roomId+"/playlist")
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
    
    func addSong(_ song: Song, addedBy user: User) throws {
        let playlistItem = PlaylistItem(song: song, addedBy: user, dateAdded: Date())
        try repo.create(id: song.id, with: playlistItem)
    }
}
