//
//  User.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable {
    @DocumentID var id: String?
    var roomCode: String
    var displayName: String
}
