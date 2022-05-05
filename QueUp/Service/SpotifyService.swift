//
//  SpotifyService.swift
//  QueUp
//
//  Created by Louis Menacho on 4/29/22.
//

import Foundation

class SpotifyService {
    
    static let shared = SpotifyService()
    
    struct Config: Codable {
        var basicAuth: String
        var clientID: String
        var redirectURL: String
        var tokenSwapURL: String
        var tokenRefreshURL: String
    }
    
    private init() {}
    
    let accountsAPI = SpotifyAccountsAPI()
    
    func initialize() async throws {
        let config = try await FirestoreRepository<Config>(collectionPath: "configs").get(id: "spotify")
        dump(config)
        accountsAPI.basicAuth = config.basicAuth
    }
    
    func getToken() async throws -> SpotifyAccountsResponse.Token {
        return try await accountsAPI.request(.token)
    }
}
