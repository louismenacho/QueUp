//
//  HomeViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation

class HomeViewModel {
    
    let session = SessionService.shared
    
    func join(roomId: String, displayName: String) async -> Result<(), Error> {
        do {
            let user = try await session.signIn(with: displayName)
            try await session.join(user: user, to: roomId)
            return .success(())
        } catch  {
            return .failure(error)
        }
    }
    
    func host(displayName: String) async -> Result<(), Error> {
        do {
            let user = try await session.signIn(with: displayName)
            try await session.createRoom(host: user)
            return .success(())
        } catch  {
            return .failure(error)
        }
    }
}
