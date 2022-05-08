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
    
    private init() {}
    
    func addSong(_ song: Song) throws {
        let currentUserId = SessionService.shared.currentUser.id
        let item = PlaylistItem(song: song, addedBy: currentUserId, dateAdded: Date())
        try playlistRepo.create(id: song.id, with: item)
    }
    
    func addListener(completion: @escaping (Result<([PlaylistItem]), Error>) -> Void) {
        playlistRepo.addListener { result in
            completion(result)
        }
    }
}
