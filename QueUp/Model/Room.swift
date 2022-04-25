//
//  Room.swift
//  QueUp
//
//  Created by Louis Menacho on 4/25/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Room: Codable {
    @DocumentID var id: String?
    var code: String
    var host: User
}
