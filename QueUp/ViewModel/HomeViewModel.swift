//
//  HomeViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation

class HomeViewModel {
    
    var currentRoom = Room() {
        didSet {
            RoomService.shared.currentRoom = currentRoom
            UserService.shared.set(roomId: currentRoom.id)
            PlaylistService.shared.set(roomId: currentRoom.id)
        }
    }
    
    func join(roomId: String, displayName: String) async -> Result<(), Error> {
        do {
            let user = try await AuthService.shared.signIn(with: displayName)
            currentRoom = try await RoomService.shared.getRoom(id: roomId)
            try await UserService.shared.addUser(user)
            try await SpotifyService.shared.initialize()
            return .success(())
        } catch  {
            return .failure(error)
        }
    }
    
    func host(displayName: String) async -> Result<(), Error> {
        do {
            let user = try await AuthService.shared.signIn(with: displayName)
            currentRoom = try await RoomService.shared.createRoom(host: user)
            try await UserService.shared.addUser(user)
            try await SpotifyService.shared.initialize()
            return .success(())
        } catch  {
            return .failure(error)
        }
    }
}
