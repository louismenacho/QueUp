//
//  APIClientError.swift
//  QueUp
//
//  Created by Louis Menacho on 5/21/22.
//

import Foundation

enum APIClientError: Error {
    case badRequest(code: Int)
    
    var statusCode: Int {
        switch self {
        case .badRequest(let code):
            return code
        }
    }
}
