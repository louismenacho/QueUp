//
//  RoomViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 5/11/22.
//

import Foundation

class RoomViewModel {
    
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
                self.spotify.updateTokens(with: room)
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
            return .failure(error)
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
    
    func linkSpotifyAccount() async -> Result<(), Error> {
        do {
            let spotifyToken = try await spotify.generateSessionToken()
            let spotifyUser = try await spotify.currentUser()
            let spotifyPlaylist = try await spotify.createPlaylist(userId: spotifyUser.id, name: "QueUp Room "+room.id)
            room.spotifyPlaylistId = spotifyPlaylist.id
            room.spotifyToken = spotifyToken.accessToken
            room.spotifyTokenExpiration = spotifyToken.expirationDate
            try roomService.updateRoom(room: room)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
//    func unlinkSpotifyAccount() async -> Result<(), Error> {
//        do {
//            room.spotifyPlaylistId = ""
//            room.spotifyToken = ""
//            room.spotifyTokenExpiration = Date()
//            try roomService.updateRoom(room: room)
//            return .success(())
//        } catch {
//            return .failure(error)
//        }
//    }
    
    func clearPlaylist() async -> Result<(), Error> {
        do {
            try await playlistService.removeAllSongs()
            if !spotify.currentPlaylistId.isEmpty {
                try await spotify.updatePlaylistItems(uris: [], rangeStart: 0, insertBefore: 0)
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func closeRoom() async -> Result<(), Error> {
        do {
            try await roomService.deleteRoom(room)
            try await userService.removeAllUsers()
            try await playlistService.removeAllSongs()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
