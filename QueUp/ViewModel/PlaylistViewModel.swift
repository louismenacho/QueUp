//
//  PlaylistViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class PlaylistViewModel {
    
    var playlist: Playlist = {
        var playlist = Playlist()
        let item = PlaylistItem(
            song: Song(title: "title", artists: ["artist"], album: "album", artworkURL: ""),
            addedBy: User(id: "", displayName: "Louis")
        )
        playlist.items = Array(repeating: item, count: 3)
        return playlist
    }()
    
}
