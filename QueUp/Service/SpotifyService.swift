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
    
    var currentPlaylistId = ""
    var searchTokenExpiration = Date()
    var sessionTokenExpiration = Date()
    
    private init() {}
    
    func initialize() async throws {
        try await tokenService.initialize()
        try await generateSearchToken()
    }
    
    func updateTokens(with room: Room) {
        currentPlaylistId = room.spotifyPlaylistId
        sessionTokenExpiration = room.spotifyTokenExpiration
        set(sessionToken: room.spotifyToken)
    }
    
    func set(sessionToken: String) {
        usersAPI.auth = .bearer(token: sessionToken)
        playlistAPI.auth = .bearer(token: sessionToken)
    }
    
    @discardableResult
    func generateSearchToken() async throws -> SpotifyAccountsResponse.Token {
        let token = try await tokenService.generateSearchToken()
        searchAPI.auth = .bearer(token: token.accessToken)
        return token
    }
    
    @discardableResult
    func generateSessionToken() async throws -> SPTSession {
        let token = try await tokenService.generateSessionToken()
        set(sessionToken: token.accessToken)
        return token
    }
    
    func isTokenExpired(tokenDate: Date) -> Bool {
        return tokenDate.compare(Date()) == .orderedAscending
    }

    func generateSessionTokenIfNeeded() async throws {
        if isTokenExpired(tokenDate: sessionTokenExpiration) && !tokenService.isGeneratingToken {
            try await generateSessionToken()
        }
    }
        
    func search(_ query: String) async throws -> SpotifySearchResponse.Search {
        if isTokenExpired(tokenDate: searchTokenExpiration) { try await generateSearchToken() }
        return try await searchAPI.request(.search(query: query, type: "track", limit: 50))
    }
    
    func currentUser() async throws -> SpotifyUsersResponse.CurrentUser {
        try await generateSessionTokenIfNeeded()
        return try await usersAPI.request(.currentUser)
    }
    
    func createPlaylist(userId: String, name: String) async throws -> SpotifyPlaylistResponse.CreatePlaylist {
        try await generateSessionTokenIfNeeded()
        return try await playlistAPI.request(.create(userId: userId, name: name))
    }
    
    @discardableResult
    func addPlaylistItems(uris: [String]) async throws -> SpotifyPlaylistResponse.Add {
        try await generateSessionTokenIfNeeded()
        return try await playlistAPI.request(.add(playlistId: currentPlaylistId, uris: uris))
    }
    
    @discardableResult
    func updatePlaylistItems(uris: [String], rangeStart: Int, insertBefore: Int) async throws -> SpotifyPlaylistResponse.Update {
        try await generateSessionTokenIfNeeded()
        return try await playlistAPI.request(.update(playlistId: currentPlaylistId, uris: uris, rangeStart: rangeStart, insertBefore: rangeStart))
    }
    
    @discardableResult
    func removePlaylistItems(uris: [String]) async throws -> SpotifyPlaylistResponse.Remove {
        try await generateSessionTokenIfNeeded()
        return try await playlistAPI.request(.remove(playlistId: currentPlaylistId, uris: uris))
    }
}
