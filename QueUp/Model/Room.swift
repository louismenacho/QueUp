//
//  Room.swift
//  QueUp
//
//  Created by Louis Menacho on 4/25/22.
//

import Foundation

struct Room: Codable {
    var id: String
    var hostId: String
    var users: [String: User] = [:]
}
