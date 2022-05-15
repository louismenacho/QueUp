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
    private var usersAPI = APIClient<SpotifyUsersAPI>()
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
            print("search token: \(token.accessToken)")
        }
    }
    
    func generatePlaylistTokenIfNeeded() async throws {
        if tokenService.isPlaylistTokenExpired() && !tokenService.isGeneratingToken {
            let token = try await tokenService.generatePlaylistToken()
            usersAPI.auth = .bearer(token: token.accessToken)
            playlistAPI.auth = .bearer(token: token.accessToken)
            print("playlist token: \(token.accessToken)")
        }
    }
        
    func search(_ query: String) async throws -> SpotifySearchResponse.Search {
        try await generateSearchTokenIfNeeded()
        return try await searchAPI.request(.search(query: query, type: "track", limit: 50))
    }
    
    func currentUser() async throws -> SpotifyUsersResponse.CurrentUser {
        try await generatePlaylistTokenIfNeeded()
        return try await usersAPI.request(.currentUser, log: true)
    }
    
    func createPlaylist(userId: String, name: String) async throws -> SpotifyPlaylistResponse.CreatePlaylist {
        try await generatePlaylistTokenIfNeeded()
        return try await playlistAPI.request(.create(userId: "melo3450", name: "QueUp"), log: true)
    }
    
    func addPlaylistItems(playlistId: String, uris: [String], position: Int) async throws -> SpotifyPlaylistResponse.Add {
        try await generatePlaylistTokenIfNeeded()
        return try await playlistAPI.request(.add(playlistId: playlistId, uris: uris, position: 0), log: true)
    }
    
    func updatePlaylistItems(playlistId: String, uris: [String], rangeStart: Int, insertBefore: Int) async throws -> SpotifyPlaylistResponse.Update {
        try await generatePlaylistTokenIfNeeded()
        return try await playlistAPI.request(.update(playlistId: playlistId, uris: uris, rangeStart: 0, insertBefore: 0), log: true)
    }
    
    func removePlaylistItems(playlistId: String, uris: [String]) async throws -> SpotifyPlaylistResponse.Remove {
        try await generatePlaylistTokenIfNeeded()
        return try await playlistAPI.request(.remove(playlistId: playlistId, uris: uris), log: true)
    }
}
