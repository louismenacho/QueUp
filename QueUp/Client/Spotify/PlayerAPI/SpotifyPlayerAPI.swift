//
//  SpotifyPlayerAPI.swift
//  QueUp
//
//  Created by Louis Menacho on 5/17/22.
//

import Foundation

enum SpotifyPlayerAPI: APIEndpoint {
    case startPlayback(contextURI: String, uri: String, position: Int)
    
    var baseURL: String {
        return "https://api.spotify.com/v1/me/player"
    }
    
    var request: APIRequest {
        var apiRequest = APIRequest(baseURL: baseURL)
        
        switch self {
        case let .startPlayback(contextURI, uri, position):
            apiRequest.method = .put
            apiRequest.path = "/play"
            apiRequest.contentType = .json
            apiRequest.bodyParams = [
                "context_uri": contextURI,
                "offset": [
                    "uri": uri
                ],
                "position_ms": position
            ]
        }
        
        return apiRequest
    }
}
