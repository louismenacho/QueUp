//
//  SearchViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class SearchViewModel {
    
    var searchResult: [Song] = {
        let song = Song(title: "title", artists: ["artist"], album: "album", artworkURL: "")
        return Array(repeating: song, count: 10)
    }()
}
