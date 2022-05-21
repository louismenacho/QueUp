//
//  RoomViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 5/11/22.
//

import Foundation
import FirebaseCrashlytics

class RoomViewModel {
    
    enum RoomViewModelError: LocalizedError {
        case roomListenerError
        case roomUpdateError
        case spotifyTokenGenerationError
        case spotifyLinkError
        case clearPlaylistError
        case endRoomSessionError
        
        var errorDescription: String? {
            switch self {
            case .roomListenerError:
                return "Could not sync room data"
            case .roomUpdateError:
                return "Could not update room"
            case .spotifyTokenGenerationError:
                return "Coult not generate Spotify token"
            case .spotifyLinkError:
                return "Could not link with Spotify"
            case .clearPlaylistError:
                return "Could not clear playlist"
            case .endRoomSessionError:
                return "Could not end room session"
            }
        }
    }
    
    var roomService = RoomService.shared
    var userService = UserService.shared
    var playlistService = PlaylistService.shared
    var spotify = SpotifyService.shared

    var room = Room()
        
    func roomListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        roomService.startListener()
        roomService.listener = { result in
            switch result {
            case .success(let room):
                self.room = room
                self.spotify.sessionPlaylistId = room.spotifyPlaylistId
                self.spotify.sessionToken = room.spotifyToken
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func updateRoom(_ room: Room) -> Result<(), Error> {
        do {
            try roomService.updateRoom(room: room)
            return .success(())
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .failure(RoomViewModelError.roomUpdateError)
        }
    }
    
    func stopListener() {
        roomService.stopListener()
    }
    
    func unsaveRoomId() {
        UserDefaultsRepository.shared.roomId = ""
    }
    
    func isHost(_ user: User) -> Bool {
        return room.hostId == user.id
    }
    
    func isSpotifyProductPremium() -> Bool {
        return room.spotifyProduct == "premium"
    }
    
    func isSpotifyLinked() -> Bool {
        return !room.spotifyPlaylistId.isEmpty
    }
    
    func isTokenExpired() -> Bool {
        return spotify.isTokenExpired(tokenExpiration: room.spotifyTokenExpiration)
    }
    
    func relinkSpotifyIfNeeded() async -> Result<(Bool), Error> {
        do {
            var room = try await roomService.getRoom()
            guard isSpotifyLinked() && spotify.isTokenExpired(tokenExpiration: room.spotifyTokenExpiration) else {
                return .success((false))
            }
            try await spotify.generateSessionToken()
            room.spotifyToken = spotify.sessionToken
            room.spotifyTokenExpiration = spotify.sessionTokenExpiration
            try roomService.updateRoom(room: room)
            return .success(true)
        } catch {
            if (error as NSError).code == 1 {
                return .success(false)
            }
            Crashlytics.crashlytics().record(error: error)
            return .failure(RoomViewModelError.spotifyTokenGenerationError)
        }
    }
    
    func linkSpotifyAccount() async -> Result<(Bool), Error> {
        do {
            try await spotify.generateSessionToken()
            let spotifyUser = try await spotify.currentUser()
            let spotifyPlaylist = try await spotify.createPlaylist(userId: spotifyUser.id, name: "QueUp Room "+room.id)
            spotify.sessionPlaylistId = spotifyPlaylist.id
            room.spotifyPlaylistId = spotifyPlaylist.id
            room.spotifyToken = spotify.sessionToken
            room.spotifyTokenExpiration = spotify.sessionTokenExpiration
            room.spotifyProduct = spotifyUser.product
            try roomService.updateRoom(room: room)
            return .success((true))
        } catch {
            if (error as NSError).code == 1 {
                return .success(false)
            }
            Crashlytics.crashlytics().record(error: error)
            return .failure(RoomViewModelError.spotifyLinkError)
        }
    }
    
    func clearPlaylist() async -> Result<(), Error> {
        do {
            try await playlistService.removeAllSongs()
            if !spotify.sessionPlaylistId.isEmpty {
                try await spotify.updatePlaylistItems(uris: [], rangeStart: 0, insertBefore: 0)
            }
            return .success(())
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .failure(RoomViewModelError.clearPlaylistError)
        }
    }
    
    func endRoomSession() async -> Result<(), Error> {
        do {
            try await roomService.deleteRoom(room)
            try await userService.removeAllUsers()
            try await playlistService.removeAllSongs()
            try await spotify.unfollowPlaylist()
            return .success(())
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .failure(RoomViewModelError.endRoomSessionError)
        }
    }
}
