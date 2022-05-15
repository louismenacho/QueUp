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
    
    let auth = AuthService.shared
    let spotify = SpotifyService.shared
    var playlistService = PlaylistService.shared
    
    var searchResult = [SearchResultItem]()
    var selectedSearchResultItem: SearchResultItem?
    
    var currentPlaylist = [PlaylistItem]()
    
    func search(query: String) async -> Result<(), Error> {
        do {
            let search = try await spotify.search(query)
            searchResult = search.tracks.items.map { track in
                SearchResultItem(
                    song: Song(
                        id: track.uri,
                        title: track.name,
                        artists: track.artists.map { $0.name },
                        album: track.album.name,
                        artworkURL: track.album.images[0].url
                    ),
                    isAdded: currentPlaylist.contains(where: { $0.song.id == track.uri })
                )
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func addSong(at index: Int) async throws -> Result<(()), Error> {
        let song = searchResult[index].song
        guard !currentPlaylist.contains(where: { $0.song.id == song.id }) else {
            return .failure(SearchViewModelError.duplicateSongError)
        }
        do {
            try playlistService.addSong(song, addedBy: auth.signedInUser)
            if !spotify.currentPlaylistId.isEmpty {
                try await spotify.addPlaylistItems(uris: [song.id])
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updateIsAddedStatus(with playlist: [PlaylistItem]) {
        currentPlaylist = playlist
        searchResult.enumerated().forEach { (index, searchResultItem) in
            searchResult[index].isAdded = playlist.contains(where: { $0.song.id == searchResultItem.song.id })
        }
    }
    
    func reset() {
        searchResult = [SearchResultItem]()
    }
}
