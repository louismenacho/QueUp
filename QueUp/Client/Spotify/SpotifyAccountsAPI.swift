//
//  SpotifyAccountsAPI.swift
//  QueUp
//
//  Created by Louis Menacho on 4/28/22.
//

import Foundation

class SpotifyAccountsAPI: APIClient {
    
    enum Endpoint {
        case token
    }
    
    var basicAuth: String = ""
            
    @discardableResult
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var request = APIRequest(baseURL: "https://accounts.spotify.com/api")
        request.authorization = .basic(base64: basicAuth)
        
        switch endpoint {
        case .token:
            request.method = .post
            request.path = "/token"
            request.contentType = .xwwwformurlencoded
            request.bodyParams = ["grant_type": "client_credentials"]
        }
        
        return try await send(apiRequest: request)
    }
}
