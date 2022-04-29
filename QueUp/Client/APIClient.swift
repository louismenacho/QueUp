//
//  APIClient.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class APIClient {
    
    enum HTTPMethod: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }
    
    enum HTTPAuthorization {
        case none
        case basic(username: String, password: String)
        case bearer(token: String)
    }
        
    enum HTTPBody: String {
        case none
        case xwwwformurlencoded = "application/x-www-form-urlencoded"
        case json = "application/json"
    }
    
    struct HTTPRequest {
        var method: HTTPMethod
        var endpoint: String
        var header: [String: String] = [:]
        var params: [String: String] = [:]
        var body: [String: Any] = [:]
        var bodyType: HTTPBody = .none
    }
    
    var baseURL: String
    var authorization: HTTPAuthorization
    
    init(baseURL: String, authorization: HTTPAuthorization = .none) {
        self.baseURL = baseURL
        self.authorization = authorization
    }
    
    func send<T: Decodable>(httpRequest: HTTPRequest) async throws -> T {
        let urlRequest = try buildURLRequest(from: httpRequest)
        print(httpRequest.method.rawValue+" "+baseURL+"/"+httpRequest.endpoint)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                }
                
                guard let data = data else {
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode > 299 {
                    print((try? JSONSerialization.jsonObject(with: data)) ?? "No data")
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    continuation.resume(with: .success(decodedData))
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }.resume()
        }
    }
    
    private func buildURLRequest(from httpRequest: HTTPRequest) throws -> URLRequest {
        var components = URLComponents(url: URL(string: baseURL)!, resolvingAgainstBaseURL: true)!
        components.path.append(httpRequest.endpoint)
        components.queryItems = httpRequest.params.isEmpty ? nil : httpRequest.params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = httpRequest.method.rawValue
        request.allHTTPHeaderFields = httpRequest.header
        
        switch authorization {
        case .basic(let username, let password):
            let base64Credentials = (username+":"+password).data(using: .utf8)!.base64EncodedString()
            request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        case .bearer(let token):
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        case .none:
            break
        }
        
        switch httpRequest.bodyType {
        case .xwwwformurlencoded:
            var components = URLComponents()
            components.queryItems = httpRequest.body.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            request.httpBody = components.query?.data(using: .utf8)
        case .json:
            request.httpBody = try JSONSerialization.data(withJSONObject: httpRequest.body, options: .prettyPrinted)
        case .none:
            break
        }
        
        return request
    }
}
