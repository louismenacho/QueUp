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
    
    var sessionPlaylistId = ""
    var sessionToken = ""
    var sessionTokenExpiration = Date()
    
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
        if !tokenService.isGeneratingSessionToken {
            let token = try await tokenService.generateSessionToken()
            setSessionToken(token.accessToken)
            sessionTokenExpiration = token.expirationDate
        }
    }
    
    func setSessionToken(_ token: String) {
        sessionToken = token
        usersAPI.auth = .bearer(token: token)
        playlistAPI.auth = .bearer(token: token)
        playerAPI.auth = .bearer(token: token)
    }

    func generateSessionTokenIfNeeded() async throws {
        if isTokenExpired(tokenDate: sessionTokenExpiration) && !tokenService.isGeneratingSessionToken {
            try await generateSessionToken()
        }
    }
    
    func isTokenExpired(tokenDate: Date) -> Bool {
        return tokenDate.compare(Date()) == .orderedAscending
    }
        
    func search(_ query: String) async throws -> SpotifySearchResponse.Search {
        if isTokenExpired(tokenDate: searchTokenExpiration) { try await generateSearchToken() }
        return try await searchAPI.request(.search(query: query, type: "track", limit: 50))
    }
    
    func currentUser() async throws -> SpotifyUsersResponse.CurrentUser {
        try await generateSessionTokenIfNeeded()
        return try await usersAPI.request(.currentUser)
    }
    
    @discardableResult
    func createPlaylist(userId: String, name: String) async throws -> SpotifyPlaylistResponse.CreatePlaylist {
        try await generateSessionTokenIfNeeded()
        return try await playlistAPI.request(.create(userId: userId, name: name))
    }
    
    @discardableResult
    func addPlaylistItems(uris: [String]) async throws -> SpotifyPlaylistResponse.Add {
        try await generateSessionTokenIfNeeded()
        return try await playlistAPI.request(.add(playlistId: sessionPlaylistId, uris: uris))
    }
    
    @discardableResult
    func updatePlaylistItems(uris: [String], rangeStart: Int, insertBefore: Int) async throws -> SpotifyPlaylistResponse.Update {
        try await generateSessionTokenIfNeeded()
        return try await playlistAPI.request(.update(playlistId: sessionPlaylistId, uris: uris, rangeStart: rangeStart, insertBefore: rangeStart))
    }
    
    @discardableResult
    func removePlaylistItems(uris: [String]) async throws -> SpotifyPlaylistResponse.Remove {
        try await generateSessionTokenIfNeeded()
        return try await playlistAPI.request(.remove(playlistId: sessionPlaylistId, uris: uris))
    }
    
    @discardableResult
    func startPlayback(contextURI: String, uri: String, position: Int = 0) async throws -> SpotifyPlayerResponse.StartPlayback {
        try await generateSessionTokenIfNeeded()
        return try await playerAPI.request(.startPlayback(contextURI: contextURI, uri: uri, position: position))
    }
}
