//
//  Room.swift
//  QueUp
//
//  Created by Louis Menacho on 4/25/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Room: Codable {
    var id: String
    var code: String
    var users: [User]
    
    init(id: String, code: String) {
        self.id = id
        self.code = code
        self.users = []
    }
}
