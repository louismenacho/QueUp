//
//  SearchViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation
import FirebaseCrashlytics

class SearchViewModel {
    
    enum SearchViewModelError: LocalizedError {
        case searchError
        case addSongError
        case duplicateSongError
        
        var errorDescription: String? {
            switch self {
            case .searchError:
               return "Could not complete search"
            case .addSongError:
               return "Could not add song"
            case .duplicateSongError:
               return "This song has already been added"
            }
        }
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
            Crashlytics.crashlytics().record(error: error)
            return .failure(SearchViewModelError.searchError)
        }
    }
    
    func addSong(at index: Int) async throws -> Result<(Song), Error> {
        let song = searchResult[index].song
        guard !currentPlaylist.contains(where: { $0.song.id == song.id }) else {
            return .failure(SearchViewModelError.duplicateSongError)
        }
        do {
            try playlistService.addSong(song, addedBy: auth.signedInUser)
            return .success(song)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .failure(SearchViewModelError.addSongError)
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
