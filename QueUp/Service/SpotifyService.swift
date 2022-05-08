//
//  SpotifyService.swift
//  QueUp
//
//  Created by Louis Menacho on 4/29/22.
//

import Foundation

class SpotifyService {
    
    struct Config: Codable {
        var basicAuth: String
        var clientID: String
        var redirectURL: String
        var tokenSwapURL: String
        var tokenRefreshURL: String
    }
    
    static let shared = SpotifyService()
    
    private var accountsAPI = APIClient<SpotifyAccountsAPI>()
    private var searchAPI = APIClient<SpotifySearchAPI>()
    
    private init() {}
    
    func initialize() async throws {
        let config = try await FirestoreRepository<Config>(collectionPath: "configs").get(id: "spotify")
        accountsAPI.auth = .basic(base64: config.basicAuth)
        
        let token = try await getToken()
        searchAPI.auth = .bearer(token: token.accessToken)
    }
    
    func getToken() async throws -> SpotifyAccountsResponse.Token {
        return try await accountsAPI.request(.token)
    }
    
    func search(_ query: String) async throws -> SpotifySearchResponse.Search {
        return try await searchAPI.request(.search(query: query, type: "track", limit: 50))
    }
}
