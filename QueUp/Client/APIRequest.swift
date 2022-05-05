//
//  APIRequest.swift
//  QueUp
//
//  Created by Louis Menacho on 5/4/22.
//

import Foundation

struct APIRequest {
    
    enum HTTPMethod: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }
    
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
    
    var method: HTTPMethod = .get
    var baseURL: String
    var path: String = ""
    var query: [String: String] = [:]
    var authorization: HTTPAuthorization = .none
    var contentType: HTTPContentType = .none
    var bodyParams: [String: Any] = [:]
    
    var url: URL {
        var components = URLComponents(url: URL(string: baseURL)!, resolvingAgainstBaseURL: true)!
        components.path.append(path)
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.url!
    }
    
    var headers: [String: String] {
        var headers = [String: String]()
        if let authorization = authorization.headerValue() {
            headers["Authorization"] = authorization
        }
        if let contentType = contentType.headerValue() {
            headers["Content-Type"] = contentType
        }
        return headers
    }
    
    var bodyData: Data? {
        get throws {
            switch contentType {
            case .none:
                return nil
            case .json:
                return try JSONSerialization.data(withJSONObject: bodyParams, options: .prettyPrinted)
            case .xwwwformurlencoded:
                var components = URLComponents()
                components.queryItems = bodyParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                return components.query?.data(using: .utf8)
            }
        }
    }
}
