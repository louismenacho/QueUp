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
    
    var users = [User]()
    var playlist = Playlist()
    
    init() {
        sessionService.startListener()
        playlistService.startListener()
    }
    
    func playlistItemsListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        playlistService.playlistItemsListener = { result in
            switch result {
            case .success(let playlist):
                self.playlist = playlist
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func sessionListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        sessionService.roomListener = { result in
            switch result {
            case .success(let room):
                self.users = Array(room.users.values)
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func stopListeners() {
        sessionService.stopListener()
        playlistService.stopListener()
    }
    
    func resetServices() {
        sessionService.reset()
        playlistService.reset()
    }
}
