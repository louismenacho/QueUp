//
//  Song.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

struct Song: Codable {
    var id: String = ""
    var title: String = ""
    var artists: [String] = []
    var album: String = ""
    var artworkURL: String = ""
}
