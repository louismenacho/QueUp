//
//  SpotifySearchAPI.swift
//  QueUp
//
//  Created by Louis Menacho on 5/5/22.
//

import Foundation

enum SpotifySearchAPI: APIEndpoint {
    
    case search(query: String, type: String, limit: Int)
    
    var baseURL: String {
        return "https://api.spotify.com/v1/search"
    }
    
    var request: APIRequest {
        var apiRequest = APIRequest(baseURL: baseURL)
        
        switch self {
        case let .search(query, type, limit):
            apiRequest.method = .get
            apiRequest.query  = [
                "q": query,
                "type": type,
                "limit": "\(limit)"
            ]
        }
        
        return apiRequest
    }
}
