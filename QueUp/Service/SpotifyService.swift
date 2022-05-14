//
//  SpotifyService.swift
//  QueUp
//
//  Created by Louis Menacho on 4/29/22.
//

import Foundation

class SpotifyService {

    static let shared = SpotifyService()
    
    private var tokenService = SpotifyTokenService.shared
    
    private var searchAPI = APIClient<SpotifySearchAPI>()
    private var playlistAPI = APIClient<SpotifyPlaylistAPI>()
    
    private init() {}
    
    func initialize() async throws {
        try await tokenService.initialize()
        try await generateSearchTokenIfNeeded()
    }
    
    func generateSearchTokenIfNeeded()  async throws {
        if tokenService.isSearchTokenExpired() {
            let token = try await tokenService.generateSearchToken()
            searchAPI.auth = .bearer(token: token.accessToken)
            print("search token: \(token)")
        }
    }
    
    func generatePlaylistTokenIfNeeded() async throws {
        if tokenService.isPlaylistTokenExpired() {
            let token = try await tokenService.generatePlaylistToken()
            playlistAPI.auth = .bearer(token: token.accessToken)
            print("playlist token: \(token.accessToken)")
        }
    }
        
    func search(_ query: String) async throws -> SpotifySearchResponse.Search {
        try await generateSearchTokenIfNeeded()
        return try await searchAPI.request(.search(query: query, type: "track", limit: 50))
    }
}
