//
//  Playlist.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

struct Playlist: Codable {
    var id: String = ""
    var items: [PlaylistItem] = []
}
