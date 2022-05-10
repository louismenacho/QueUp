//
//  HomeViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation

class HomeViewModel {
    
    let auth = AuthService.shared
    let session = SessionService.shared
    let spotifyService = SpotifyService.shared
    
    func join(roomId: String, displayName: String) async -> Result<(), Error> {
        do {
            let user = try await auth.signIn(with: displayName)
            try await session.join(user: user, to: roomId)
            try await spotifyService.initialize()
            session.startListener()
            return .success(())
        } catch  {
            return .failure(error)
        }
    }
    
    func host(displayName: String) async -> Result<(), Error> {
        do {
            let user = try await auth.signIn(with: displayName)
            try await session.createRoom(host: user)
            try await spotifyService.initialize()
            session.startListener()
            return .success(())
        } catch  {
            return .failure(error)
        }
    }
}
