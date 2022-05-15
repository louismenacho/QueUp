//
//  SpotifyUsersAPI.swift
//  QueUp
//
//  Created by Louis Menacho on 5/14/22.
//

import Foundation


enum SpotifyUsersAPI: APIEndpoint {
    case currentUser
    
    var baseURL: String {
        return "https://api.spotify.com/v1"
    }
    
    var request: APIRequest {
        var apiRequest = APIRequest(baseURL: baseURL)
        
        switch self {
        case .currentUser:
            apiRequest.method = .get
            apiRequest.path = "/me"
        }
        
        return apiRequest
    }
}
