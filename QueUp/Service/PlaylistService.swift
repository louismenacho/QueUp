//
//  PlaylistService.swift
//  QueUp
//
//  Created by Louis Menacho on 5/8/22.
//

import Foundation

class PlaylistService {

    var playlistRepo: FirestoreRepository<PlaylistItem> = .init(collectionPath: "rooms/ROOM_ID/playlist")
    
    var currentPlaylist: [PlaylistItem] = []
    
    var playlistListener: ((Result<[PlaylistItem], Error>) -> Void)?
    
    func setRepoPath(_ path: String) {
        stopListener()
        self.playlistRepo = .init(collectionPath: path)
    }
    
    func startListener() {
        guard playlistRepo.collectionListener == nil else { return }
        playlistRepo.addListener { result in
            self.playlistListener?( Result {
                self.currentPlaylist = try result.get()
                return self.currentPlaylist
            })
        }
    }
    
    func stopListener() {
        playlistRepo.removeListener()
    }
    
    func reset() {
        currentPlaylist = []
        playlistListener = nil
    }
    
    func addSong(_ song: Song, addedBy user: User) throws {
        let playlistItem = PlaylistItem(song: song, addedBy: user, dateAdded: Date())
        try playlistRepo.create(id: song.id, with: playlistItem)
    }
}
