//
//  PlaylistService.swift
//  QueUp
//
//  Created by Louis Menacho on 5/8/22.
//

import Foundation

class PlaylistService {
    
    static let shared = PlaylistService()
    
    let playlistRepo = PlaylistRepository.shared
    
    var playlistItemsListener: ((Result<[PlaylistItem], Error>) -> Void)?
    
    private init() {}
    
    func addSong(_ song: Song) throws {
        let currentUserId = AuthService.shared.currentUser.id
        let item = PlaylistItem(song: song, addedBy: currentUserId, dateAdded: Date())
        try playlistRepo.create(id: song.id, with: item)
    }
        
    func startListener() {
        guard playlistRepo.collectionListener == nil else { return }
        playlistRepo.addListener { result in
            self.playlistItemsListener?(result)
        }
    }
    
    func stopListener() {
        playlistRepo.removeListener()
    }
    
    func reset() {
        playlistItemsListener = nil
    }
}