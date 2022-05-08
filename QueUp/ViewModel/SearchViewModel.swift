//
//  SearchViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class SearchViewModel {
    
    let spotifyService = SpotifyService.shared
    
    var searchResult = [Song]()
    
    func initialize() async -> Result<(), Error> {
        do {
            try await spotifyService.initialize()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func search(query: String) async -> Result<(), Error> {
        do {
            let search = try await spotifyService.search(query)
            searchResult = search.tracks.items.map { track in
                Song(
                    title: track.name,
                    artists: track.artists.map { $0.name },
                    album: track.album.name,
                    artworkURL: track.album.images[0].url
                )
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
