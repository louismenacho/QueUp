//
//  PlaylistViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class PlaylistViewModel {
    
    let sessionService = SessionService.shared
    let playlistService = PlaylistService.shared
    
    var playlistItems: [PlaylistItem] = {
        var playlist = [PlaylistItem]()
        let item = PlaylistItem(
            song: Song(title: "title", artists: ["artist"], album: "album", artworkURL: ""),
            addedBy: "user"
        )
        playlist = Array(repeating: item, count: 3)
        return playlist
    }()
    
    func playlistChangeListener(completion: @escaping (Result<(), Error>) -> Void) {
        playlistService.addListener { result in
            switch result {
            case .success(let playlistItems):
                self.playlistItems = playlistItems
                self.resolveAddedByIds()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func resolveAddedByIds() {
        for i in 0..<playlistItems.count {
            let userId = playlistItems[i].addedBy
            playlistItems[i].addedBy = sessionService.currentRoom.users[userId]?.displayName ?? "Unknown user"
        }
    }
}
