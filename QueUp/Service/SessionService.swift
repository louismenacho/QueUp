//
//  SessionService.swift
//  QueUp
//
//  Created by Louis Menacho on 4/25/22.
//

import Foundation
import FirebaseAuth

class SessionService {
    
    static let shared = SessionService()
    
    let roomRepo = RoomRepository.shared
    
    var currentRoom = Room()
    
    var roomListener: ((Result<(), Error>) -> Void)?
    
    private init() {}
    
    func join(user: User, to roomId: String) async throws {
        var room = try await roomRepo.get(id: roomId)
        guard room.users.count < 8 else {
            print("Room is full")
            return
        }
        room.users[user.id] = user
        try roomRepo.update(id: room.id, with: room)
        currentRoom = room
    }
    
    func createRoom(host: User) async throws {
        var room = Room(id: randomString(of: 4), hostId: host.id)
        //TODO: - check here if exists, else regenerate
        room.users[host.id] = host
        try roomRepo.create(id: room.id, with: room)
        currentRoom = room
    }
    
    func startListener() {
        guard roomRepo.collectionListener == nil else { return }
        roomRepo.addListener(id: currentRoom.id) { result in
            self.roomListener?(result.map { self.currentRoom = $0 })
        }
    }
    
    func stopListener() {
        roomRepo.removeListener()
    }
    
    func reset() {
        currentRoom = Room()
        roomListener = nil
    }
    
    func userIdToDisplayName(id: String) -> String {
        return currentRoom.users[id]?.displayName ?? "Unknown user"
    }
    
    private func randomString(of length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let string = String(repeating: "_", count: length)
        return String(string.map { _ in letters.randomElement()! })
    }
}
