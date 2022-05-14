//
//  SpotifyPlaylistAPI.swift
//  QueUp
//
//  Created by Louis Menacho on 5/13/22.
//

import Foundation

enum SpotifyPlaylistAPI: APIEndpoint {
    
    case create(userId: String, name: String)
    case update(playlistId: String, uris: [String])
    
    var baseURL: String {
        return "https://api.spotify.com/v1"
    }
    
    var request: APIRequest {
        var apiRequest = APIRequest(baseURL: baseURL)
        
        switch self {
        case let .create(userId, name):
            apiRequest.method = .post
            apiRequest.path = "/users/"+userId+"/playlists"
            apiRequest.contentType = .json
            apiRequest.bodyParams = [
                "name": name
            ]
        case let .update(playlistId, uris):
            apiRequest.method = .put
            apiRequest.path = "/playlists/"+playlistId+"/tracks"
            apiRequest.contentType = .json
            apiRequest.bodyParams = [
                "uris": uris.joined(separator: ",")
            ]
        }
        
        return apiRequest
    }
}
