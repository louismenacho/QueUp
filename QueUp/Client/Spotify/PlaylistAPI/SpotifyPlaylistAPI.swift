//
//  SpotifyPlaylistAPI.swift
//  QueUp
//
//  Created by Louis Menacho on 5/13/22.
//

import Foundation

enum SpotifyPlaylistAPI: APIEndpoint {
    
    case create(userId: String, name: String)
    case add(playlistId: String, uris: [String])
    case update(playlistId: String, uris: [String], rangeStart: Int, insertBefore: Int)
    case remove(playlistId: String, uris: [String])
    
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
        case let .add(playlistId, uris):
            apiRequest.method = .post
            apiRequest.path = "/playlists/"+playlistId+"/tracks"
            apiRequest.contentType = .json
            apiRequest.bodyParams = [
                "uris": uris
            ]
        case let .update(playlistId, uris, rangeStart, insertBefore):
            apiRequest.method = .put
            apiRequest.path = "/playlists/"+playlistId+"/tracks"
            apiRequest.contentType = .json
            apiRequest.query = ["uris": uris.joined(separator: ",")]
            apiRequest.bodyParams = [
                "range_start": rangeStart,
                "insert_before": insertBefore
            ]
        case let .remove(playlistId, uris):
            apiRequest.method = .delete
            apiRequest.path = "/playlists/"+playlistId+"/tracks"
            apiRequest.contentType = .json
            apiRequest.bodyParams = [
                "tracks" : uris.map {
                    ["uri": $0]
                }
            ]
        }
        
        return apiRequest
    }
}
