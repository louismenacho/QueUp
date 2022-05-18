//
//  PlaylistViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class PlaylistViewModel {
    
    var auth = AuthService.shared
    var service = PlaylistService.shared
    var spotify = SpotifyService.shared
    
    var playlist = [PlaylistItem]()
    var spotifyPlaylistId: String = ""
    
    func playlistListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        service.startListener()
        service.listener = { result in
            switch result {
            case .success(let playlist):
                self.playlist = playlist.sorted(by: { $0.dateAdded < $1.dateAdded })
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func stopListener() {
        service.stopListener()
    }
    
    func playSong(song: Song) async throws {
        try await spotify.startPlayback(contextURI: "spotify:playlist:"+spotifyPlaylistId, uri: song.id)
    }
    
    func updateAddedByDisplayNames(with users: [User]) {
        playlist.enumerated().forEach { (index, playlistItem) in
            if let matchedUser = users.first(where: { $0.id == playlistItem.addedBy.id }) {
                playlist[index].addedBy.displayName = matchedUser.displayName
                if auth.signedInUser.id == matchedUser.id {
                    playlist[index].addedBy.displayName = "You"
                }
            }
        }
    }
}
