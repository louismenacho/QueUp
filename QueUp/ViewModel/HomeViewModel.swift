//
//  HomeViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation
import FirebaseCrashlytics

class HomeViewModel {
    
    enum HomeViewModelError: LocalizedError {
        case roomCapacityReached(roomId: String)
        case joinRoomError
        case hostRoomError
        
        var errorDescription: String? {
            switch self {
            case .roomCapacityReached(let roomId):
               return "Room \(roomId) is full"
            case .joinRoomError:
               return "Could not join room"
            case .hostRoomError:
               return "Could not host room"
            }
        }
    }
    
    var lastRoomId: String {
        UserDefaultsRepository.shared.roomId
    }
    
    var displayName: String {
        UserDefaultsRepository.shared.displayName
    }
    
    func join(roomId: String, displayName: String) async -> Result<(), Error> {
        do {
            var user = try await AuthService.shared.signIn(with: displayName)
            let room = try await RoomService.shared.getRoom(id: roomId)
            updateServices(with: room)
            
            let users = try await UserService.shared.listUsers()
            guard users.count < 8 || users.contains(where: { $0.id == user.id }) else {
                return .failure(HomeViewModelError.roomCapacityReached(roomId: room.id))
            }
            
            if let existingUser = users.first(where: { $0.id == user.id }) {
                user.dateAdded = existingUser.dateAdded
            }
            try await UserService.shared.addUser(user)
            try await SpotifyService.shared.initialize()
            
            UserDefaultsRepository.shared.roomId = room.id
            UserDefaultsRepository.shared.displayName = user.displayName
            return .success(())
        } catch  {
            Crashlytics.crashlytics().record(error: error)
            return .failure(HomeViewModelError.joinRoomError)
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
            Crashlytics.crashlytics().record(error: error)
            return .failure(HomeViewModelError.hostRoomError)
        }
    }
    
    private func updateServices(with currentRoom: Room) {
        RoomService.shared.currentRoom = currentRoom
        UserService.shared.set(roomId: currentRoom.id)
        PlaylistService.shared.set(roomId: currentRoom.id)
    }
}
