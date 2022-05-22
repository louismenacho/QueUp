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
    private var playerAPI = APIClient<SpotifyPlayerAPI>()

    var searchTokenExpiration = Date()
    var sessionTokenExpiration = Date()
    var sessionPlaylistId = ""
    
    var sessionToken = "" {
        didSet {
            usersAPI.auth = .bearer(token: sessionToken)
            playlistAPI.auth = .bearer(token: sessionToken)
            playerAPI.auth = .bearer(token: sessionToken)
        }
    }
    
    private init() {}
    
    func initialize() async throws {
        try await tokenService.initialize()
        try await generateSearchToken()
    }
    
    func generateSearchToken() async throws {
        let token = try await tokenService.generateSearchToken()
        searchAPI.auth = .bearer(token: token.accessToken)
        searchTokenExpiration = Date().addingTimeInterval(Double(token.expiresIn))
    }
    
    func generateSessionToken() async throws {
        let token = try await tokenService.generateSessionToken()
        sessionToken = token.accessToken
        sessionTokenExpiration = token.expirationDate
    }

    func generateSessionTokenIfNeeded() async throws {
        if isTokenExpired(tokenExpiration: sessionTokenExpiration) {
            try await generateSessionToken()
        }
    }
    
    func isTokenExpired(tokenExpiration: Date) -> Bool {
        return tokenExpiration.compare(Date()) == .orderedAscending
    }
        
    func search(_ query: String) async throws -> SpotifySearchResponse.Search {
        if isTokenExpired(tokenExpiration: searchTokenExpiration) { try await generateSearchToken() }
        return try await searchAPI.request(.search(query: query, type: "track", limit: 50))
    }
    
    func currentUser() async throws -> SpotifyUsersResponse.CurrentUser {
        try await usersAPI.request(.currentUser)
    }
    
    @discardableResult
    func createPlaylist(userId: String, name: String) async throws -> SpotifyPlaylistResponse.CreatePlaylist {
        try await playlistAPI.request(.create(userId: userId, name: name))
    }
    
    @discardableResult
    func addPlaylistItems(uris: [String]) async throws -> SpotifyPlaylistResponse.Add {
        try await playlistAPI.request(.add(playlistId: sessionPlaylistId, uris: uris))
    }
    
    @discardableResult
    func updatePlaylistItems(uris: [String], rangeStart: Int = 0, insertBefore: Int = 0) async throws -> SpotifyPlaylistResponse.Update {
        try await playlistAPI.request(.update(playlistId: sessionPlaylistId, uris: uris, rangeStart: rangeStart, insertBefore: rangeStart))
    }
    
    @discardableResult
    func removePlaylistItems(uris: [String]) async throws -> SpotifyPlaylistResponse.Remove {
        return try await playlistAPI.request(.remove(playlistId: sessionPlaylistId, uris: uris))
    }
    
    func unfollowPlaylist() async throws {
        try await playlistAPI.request(.unfollow(playlistId: sessionPlaylistId))
    }
    
    func startPlayback(contextURI: String? = nil, uri: String, position: Int = 0) async throws {
        let contextURI = contextURI == nil ? "spotify:playlist:"+sessionPlaylistId : contextURI
        try await playerAPI.request(.startPlayback(contextURI: contextURI!, uri: uri, position: position))
    }
}
