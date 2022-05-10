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
    
    var currentPlaylist = Playlist()
    
    var playlistItemsListener: ((Result<Playlist, Error>) -> Void)?
    
    private var currentUser: User { AuthService.shared.currentUser }
    private var currentRoom: Room { SessionService.shared.currentRoom }
    
    private init() {}
    
    func addSong(_ song: Song) throws {
        let playlistItem = PlaylistItem(song: song, addedBy: currentUser.id, dateAdded: Date())
        currentPlaylist.items.append(playlistItem)
        try playlistRepo.update(id: currentRoom.id, with: currentPlaylist)
    }
        
    func startListener() {
        guard playlistRepo.collectionListener == nil else { return }
        playlistRepo.addListener(id: currentRoom.id) { result in
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
