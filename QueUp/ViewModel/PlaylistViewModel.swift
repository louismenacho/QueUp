//
//  PlaylistViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation
import FirebaseCrashlytics

class PlaylistViewModel {
    
    enum PlaylistViewModelError: LocalizedError {
        case playlistListenerError
        case playSongError
        case removeSongError
        case updateSpotifyPlaylistError
        case spotifyPlayerInactive
        
        var errorDescription: String? {
            switch self {
            case .playlistListenerError:
               return "Could not sync playlist data"
            case .playSongError:
               return "Could not play song"
            case .removeSongError:
               return "Could not remove song"
            case .updateSpotifyPlaylistError:
               return "Could not update Spotify playlist"
            case .spotifyPlayerInactive:
                return "Spotify must be playing music"
            }
        }
    }
    
    var auth = AuthService.shared
    var service = PlaylistService.shared
    var spotify = SpotifyService.shared
    
    var playlist = [PlaylistItem]()
    var spotifyPlaylistId: String = ""
    var shouldUpdateSpotifyPlaylist: Bool = false
    var fairMode: Bool = true
    
    func playlistListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        service.startListener()
        service.listener = { result in
            switch result {
            case .success(let playlist):
                self.playlist = playlist.sorted(by: { $0.dateAdded < $1.dateAdded })
                if self.fairMode {
                    self.playlist = self.sortedFairly(playlist: self.playlist)
                }
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func stopListener() {
        service.stopListener()
    }
    
    func playSong(song: Song) async -> Result<(), Error> {
        do {
            try await spotify.startPlayback(contextURI: "spotify:playlist:"+spotifyPlaylistId, uri: song.id)
            return .success(())
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .failure(PlaylistViewModelError.playSongError)
        }
    }
    
    func removeSong(at index: Int) async -> Result<(), Error> {
        let song = playlist[index].song
        do {
            try await service.removeSong(song)
            return .success(())
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .failure(PlaylistViewModelError.removeSongError)
        }
    }
    
    func updateSpotifyPlaylist() async -> Result<(), Error> {
        shouldUpdateSpotifyPlaylist = false
        do {
            try await spotify.updatePlaylistItems(uris: playlist.map { $0.song.id })
            return .success(())
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .failure(PlaylistViewModelError.updateSpotifyPlaylistError)
        }
    }
    
    func updateAddedByDisplayNames(with users: [User]) {
        playlist.enumerated().forEach { (index, playlistItem) in
            if let matchedUser = users.first(where: { $0.id == playlistItem.addedBy.id }) {
                playlist[index].addedBy.displayName = matchedUser.displayName
                if auth.signedInUser.id == matchedUser.id {
                    playlist[index].addedBy.displayName = "You"
                }
            }
        }
    }
    
    func sortedFairly(playlist: [PlaylistItem]) -> [PlaylistItem] {
        let set = NSOrderedSet(array: playlist.map { $0.addedBy.id }).array as! [String]
        var playlist = playlist
        var fairPlaylist = [PlaylistItem]()
        while !playlist.isEmpty {
            set.forEach { userId in
                if let index = playlist.firstIndex(where: { $0.addedBy.id == userId }) {
                    fairPlaylist.append(playlist.remove(at: index))
                }
            }
        }
        return fairPlaylist
    }
}
