//
//  SearchViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class SearchViewModel {
    
    enum SearchViewModelError: Error {
        case duplicateSongError
    }
    
    let spotifyService = SpotifyService.shared
    let playlistService = PlaylistService.shared
    
    var searchResult = [SearchResultItem]()
    var currentPlaylist = Playlist()
    var selectedSearchResultItem: SearchResultItem?
    
    func search(query: String) async -> Result<(), Error> {
        do {
            let search = try await spotifyService.search(query)
            searchResult = search.tracks.items.map { track in
                SearchResultItem(
                    song: Song(
                        id: track.uri,
                        title: track.name,
                        artists: track.artists.map { $0.name },
                        album: track.album.name,
                        artworkURL: track.album.images[0].url
                    ),
                    isAdded: currentPlaylist.items.contains(where: { $0.song.id == track.uri })
                )
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func addSong(at index: Int) -> Result<(()), Error> {
        guard !currentPlaylist.items.contains(where: { $0.song.id == searchResult[index].song.id }) else {
            print("Song already exists in playlist")
            return .failure(SearchViewModelError.duplicateSongError)
        }
        searchResult[index].isAdded = true
        do {
            try playlistService.addSong(searchResult[index].song)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func reset() {
        searchResult = [SearchResultItem]()
    }
}
