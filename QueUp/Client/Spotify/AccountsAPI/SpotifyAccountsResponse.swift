//
//  SpotifyAccountsResponse.swift
//  QueUp
//
//  Created by Louis Menacho on 5/4/22.
//

import Foundation

struct SpotifyAccountsResponse {
    
    struct Token: Codable {
        var accessToken: String
        var tokenType: String
        var expiresIn: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case expiresIn = "expires_in"
        }
    }
}
