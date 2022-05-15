//
//  SpotifyUsersResponse.swift
//  QueUp
//
//  Created by Louis Menacho on 5/14/22.
//

import Foundation

struct SpotifyUsersResponse {
    
    // MARK: - CurrentUserResponse
    struct CurrentUser: Codable {
        var displayName: String?
        var externalUrls: ExternalUrls?
        var followers: Followers?
        var href: String?
        var id: String
        var images: [Image]?
        var type, uri: String?
        
        enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
            case externalUrls = "external_urls"
            case followers, href, id, images, type, uri
        }
        
        // MARK: - ExternalUrls
        struct ExternalUrls: Codable {
            var spotify: String?
        }
        
        // MARK: - Followers
        struct Followers: Codable {
            var href: JSONNull?
            var total: Int?
        }
        
        // MARK: - Image
        struct Image: Codable {
            var height: JSONNull?
            var url: String?
            var width: JSONNull?
        }
        
        // MARK: - Encode/decode helpers
        
        class JSONNull: Codable, Hashable {
            
            public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
                return true
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(0)
            }
            
            public init() {}
            
            public required init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encodeNil()
            }
        }
    }
}
