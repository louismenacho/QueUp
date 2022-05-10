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
    let spotifyService = SpotifyService.shared
    
    init() {
        playlistService.startListener()
    }
    
    var playlistItems = [PlaylistItem]()
    
    
    func playlistItemsListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        playlistService.playlistItemsListener = { result in
            switch result {
            case .success(let playlistItems):
                self.playlistItems = playlistItems
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func sessionListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        sessionService.roomListener = { result in
            switch result {
            case .success:
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
}
