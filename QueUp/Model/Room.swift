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
    var host: User
}
