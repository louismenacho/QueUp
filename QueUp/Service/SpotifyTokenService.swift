//
//  SpotifyTokenService.swift
//  QueUp
//
//  Created by Louis Menacho on 5/14/22.
//

import Foundation

class SpotifyTokenService: NSObject {
    
    static let shared = SpotifyTokenService()
    
    struct Config: Codable {
        var basicAuth: String
        var clientID: String
        var redirectURL: String
        var tokenSwapURL: String
        var tokenRefreshURL: String
    }
    
    private var accountsAPI = APIClient<SpotifyAccountsAPI>()
    private var sessionConfig: SPTConfiguration?
    private var sessionManager: SPTSessionManager?
    private var sessionDelegateCallback: ((Result<SPTSession, Error>) -> ())?
    private let sessionScope: SPTScope = [
        .appRemoteControl,
        .userReadPlaybackState,
        .userModifyPlaybackState,
        .playlistReadPrivate,
        .playlistModifyPrivate,
        .playlistModifyPublic
    ]
    
    var isGeneratingToken: Bool = false
    
    private override init() {}
    
    func initialize() async throws {
        let config = try await FirestoreRepository<Config>(collectionPath: "configs").get(id: "spotify")
        let sessionConfig = SPTConfiguration(clientID: config.clientID, redirectURL: URL(string: config.redirectURL)!)
        sessionConfig.tokenSwapURL = URL(string: config.tokenSwapURL)!
        sessionConfig.tokenRefreshURL = URL(string: config.tokenRefreshURL)!
        self.accountsAPI.auth = .basic(base64: config.basicAuth)
        self.sessionConfig = sessionConfig
        self.sessionManager = SPTSessionManager(configuration: sessionConfig, delegate: self)
    }
    
    func generateSearchToken() async throws -> SpotifyAccountsResponse.Token {
        return try await accountsAPI.request(.token)
    }
    
    func generateSessionToken() async throws -> SPTSession {
        isGeneratingToken = true
        if sessionManager?.session == nil {
            DispatchQueue.main.async {
                self.sessionManager?.initiateSession(with: self.sessionScope, options: .default)
            }
        } else {
            DispatchQueue.main.async {
                self.sessionManager?.renewSession()
            }
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<SPTSession, Error>) in
            self.sessionDelegateCallback = { result in
                continuation.resume(with: result)
                self.isGeneratingToken = false
            }
        }
    }
    
    func handleOpenURLCallback(url: URL) {
        sessionManager?.application(UIApplication.shared, open: url, options: [:])
    }
}

extension SpotifyTokenService: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("sessionManager did initiate session")
        sessionDelegateCallback?(.success(session))
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("sessionManager did renew session")
        sessionDelegateCallback?(.success(session))
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("sessionManager did fail with error")
        sessionDelegateCallback?(.failure(error))
    }
}
