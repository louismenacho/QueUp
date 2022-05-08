//
//  SpotifyAccountsAPI.swift
//  QueUp
//
//  Created by Louis Menacho on 4/28/22.
//

import Foundation

enum SpotifyAccountsAPI: APIEndpoint {
    
    case token
    
    var baseURL: String {
        return "https://accounts.spotify.com/api"
    }
    
    var request: APIRequest {
        var apiRequest = APIRequest(baseURL: baseURL)
        
        switch self {
        case .token:
            apiRequest.method = .post
            apiRequest.path = "/token"
            apiRequest.contentType = .xwwwformurlencoded
            apiRequest.bodyParams = ["grant_type": "client_credentials"]
        }
        
        return apiRequest
    }
}
