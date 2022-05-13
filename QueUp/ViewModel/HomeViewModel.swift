//
//  HomeViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation

class HomeViewModel {
    
    var roomId: String {
        UserDefaultsRepository.shared.roomId
    }
    
    var displayName: String {
        UserDefaultsRepository.shared.displayName
    }
    
    func join(roomId: String, displayName: String) async -> Result<(), Error> {
        do {
            let user = try await AuthService.shared.signIn(with: displayName)
            let room = try await RoomService.shared.getRoom(id: roomId)
            
            updateServices(with: room)
            try await UserService.shared.addUser(user)
            try await SpotifyService.shared.initialize()
            
            UserDefaultsRepository.shared.roomId = room.id
            UserDefaultsRepository.shared.displayName = user.displayName
            return .success(())
        } catch  {
            return .failure(error)
        }
    }
    
    func host(displayName: String) async -> Result<(), Error> {
        do {
            let user = try await AuthService.shared.signIn(with: displayName)
            let room = try await RoomService.shared.createRoom(host: user)
            
            updateServices(with: room)
            try await UserService.shared.addUser(user)
            try await SpotifyService.shared.initialize()
            
            UserDefaultsRepository.shared.roomId = room.id
            UserDefaultsRepository.shared.displayName = user.displayName
            return .success(())
        } catch  {
            return .failure(error)
        }
    }
    
    private func updateServices(with currentRoom: Room) {
        RoomService.shared.currentRoom = currentRoom
        UserService.shared.set(roomId: currentRoom.id)
        PlaylistService.shared.set(roomId: currentRoom.id)
    }
}
