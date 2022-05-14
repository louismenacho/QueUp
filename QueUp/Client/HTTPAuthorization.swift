//
//  HTTPAuthorization.swift
//  QueUp
//
//  Created by Louis Menacho on 5/7/22.
//

import Foundation

enum HTTPAuthorization {
    case none
    case basic(base64: String)
    case bearer(token: String)
    
    func headerValue() -> String? {
        switch self {
        case .none:
            return nil
        case .basic(let base64):
            return "Basic \(base64)"
        case .bearer(let token):
            return "Bearer \(token)"
        }
    }
}
