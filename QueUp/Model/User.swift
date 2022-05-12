//
//  User.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation

struct User: Codable {
    var id: String = ""
    var displayName: String = ""
    var dateAdded: Date = .init()
}
