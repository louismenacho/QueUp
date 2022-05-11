//
//  PlaylistViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class PlaylistViewModel {
    
    let spotifyService = SpotifyService.shared
    var userService: UserService { SessionService.shared.userService }
    var playlistService: PlaylistService { SessionService.shared.playlistService }
    
    var users = [User]()
    var playlist = [PlaylistItem]()
    
    init() {
        userService.startListener()
        playlistService.startListener()
    }
    
    func usersListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        userService.usersListener = { result in
            switch result {
            case .success(let users):
                self.users = users
                self.playlist.enumerated().forEach { (index, playlistItem) in
                    self.playlist[index].addedBy.displayName = users.first(where: { $0.id == playlistItem.addedBy.id })?.displayName ?? "unknown user"
                }
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func playlistListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        playlistService.playlistListener = { result in
            switch result {
            case .success(let playlist):
                self.playlist = playlist
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func stopListeners() {
        userService.stopListener()
        playlistService.stopListener()
    }
    
    func resetServices() {
        userService.reset()
        playlistService.reset()
    }
}
