//
//  PlaylistItem.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

struct PlaylistItem: Codable {
    var song: Song = .init()
    var addedBy: User = .init()
    var dateAdded: Date = .init()
}
