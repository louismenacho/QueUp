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
    let spotifyService = SpotifyService.shared
    var playlistService: PlaylistService { SessionService.shared.playlistService }
    
    var searchResult = [SearchResultItem]()
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
                    isAdded: playlistService.currentPlaylist.contains(where: { $0.song.id == track.uri })
                )
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func addSong(at index: Int) -> Result<(()), Error> {
        guard !playlistService.currentPlaylist.contains(where: { $0.song.id == searchResult[index].song.id }) else {
            print("Song already exists in playlist")
            return .failure(SearchViewModelError.duplicateSongError)
        }
        searchResult[index].isAdded = true
        do {
            try playlistService.addSong(searchResult[index].song, addedBy: auth.currentUser)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func reset() {
        searchResult = [SearchResultItem]()
    }
}
