//
//  HTTPContentType.swift
//  QueUp
//
//  Created by Louis Menacho on 5/7/22.
//

import Foundation

enum HTTPContentType {
    case none
    case json
    case xwwwformurlencoded
    
    func headerValue() -> String? {
        switch self {
        case .none:
            return nil
        case .json:
            return "application/json"
        case .xwwwformurlencoded:
            return "application/x-www-form-urlencoded"
        }
    }
    }
