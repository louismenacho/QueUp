//
//  PlaylistViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class PlaylistViewModel {
    
    var service = PlaylistService.shared
    var spotify = SpotifyService.shared
    
    var playlist = [PlaylistItem]()
    
    func playlistListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        service.startListener()
        service.listener = { result in
            switch result {
            case .success(let playlist):
                self.playlist = playlist
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func stopListener() {
        service.stopListener()
    }
    
    func updateAddedByDisplayNames(with users: [User]) {
        playlist.enumerated().forEach { (index, playlistItem) in
            playlist[index].addedBy.displayName = users.first(where: { $0.id == playlistItem.addedBy.id })?.displayName ?? "unknown user"
        }
    }
}
