//
//  SessionService.swift
//  QueUp
//
//  Created by Louis Menacho on 4/25/22.
//

import Foundation

class SessionService {
    
    static let shared = SessionService()
    
    var userService = UserService()
    var playlistService = PlaylistService()
    
    let roomRepo = FirestoreRepository<Room>(collectionPath: "rooms")
    
    var currentRoom = Room()
    
    var roomListener: ((Result<(Room), Error>) -> Void)?
    
    private init() {}
    
    func join(user: User, to roomId: String) async throws {
        let room = try await roomRepo.get(id: roomId)
        userService.setRepoPath("rooms/"+room.id+"/users")
        playlistService.setRepoPath("rooms/"+room.id+"/playlist")
        
        let users = try await userService.getUsers()
        guard users.count < 8 else {
            print("Room is full")
            return
        }
        
        try userService.addUser(user)
        currentRoom = room
    }
    
    func createRoom(host: User) async throws {
        let room = Room(id: randomString(of: 4), hostId: host.id)
        userService.setRepoPath("rooms/"+room.id+"/users")
        playlistService.setRepoPath("rooms/"+room.id+"/playlist")
        
        //TODO: - check here if exists, else regenerate
        try roomRepo.create(id: room.id, with: room)
        try userService.addUser(host)
        currentRoom = room
    }
    
    func startListener() {
        guard roomRepo.collectionListener == nil else { return }
        roomRepo.addListener(id: currentRoom.id) { result in
            self.roomListener?(result)
        }
    }
    
    func stopListener() {
        roomRepo.removeListener()
    }
    
    func reset() {
        currentRoom = Room()
        roomListener = nil
    }
    
    private func randomString(of length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let string = String(repeating: "_", count: length)
        return String(string.map { _ in letters.randomElement()! })
    }
}
