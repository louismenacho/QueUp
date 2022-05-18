//
//  RoomService.swift
//  QueUp
//
//  Created by Louis Menacho on 4/25/22.
//

import Foundation

class RoomService {
    
    static let shared = RoomService()
        
    let repo = FirestoreRepository<Room>(collectionPath: "rooms")
    
    var listener: ((Result<(Room), Error>) -> Void)?
    
    var currentRoom = Room()
    
    private init() {}
    
    func startListener() {
        guard repo.collectionListener == nil else { return }
        repo.addListener(id: currentRoom.id) { result in
            self.listener?(result)
        }
    }
    
    func stopListener() {
        repo.removeListener()
        listener = nil
    }
    
    func getRoom(id: String? = nil) async throws -> Room {
        return try await repo.get(id: id ?? currentRoom.id)
    }
    
    func createRoom(host: User) async throws -> Room {
        let room = Room(id: randomString(of: 4), hostId: host.id)
        try repo.create(id: room.id, with: room)
        return room
    }
    
    func updateRoom(room: Room) throws {
        try repo.update(id: room.id, with: room)
    }
    
    func deleteRoom(_ room: Room) async throws {
        try await repo.delete(id: room.id)
    }
    
    private func randomString(of length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let string = String(repeating: "_", count: length)
        return String(string.map { _ in letters.randomElement()! })
    }
}
