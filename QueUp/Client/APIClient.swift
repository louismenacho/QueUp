//
//  APIClient.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import Foundation

class APIClient<Endpoint: APIEndpoint> {
    
    enum APIClientError: Error {
        case badRequest(code: Int)
    }
    
    var auth: HTTPAuthorization = .none
    var log: Bool = false
    
    @discardableResult
    func request<T: Decodable>(_ endpoint: Endpoint, log flag: Bool = false) async throws -> T {
        var endpointRequest = endpoint.request
        endpointRequest.authorization = auth
        return try await send(apiRequest: endpointRequest)
    }
    
    private func send<T: Decodable>(apiRequest: APIRequest) async throws -> T {
        var urlRequest = URLRequest(url: apiRequest.url)
        urlRequest.httpMethod = apiRequest.method.rawValue
        urlRequest.allHTTPHeaderFields = apiRequest.headers
        urlRequest.httpBody = try apiRequest.bodyData
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode > 299 {
                    continuation.resume(with: .failure(APIClientError.badRequest(code: response.statusCode)))
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data ?? Data())
                    continuation.resume(with: .success(decodedData))
                } catch {
                    continuation.resume(with: .failure(error))
                }
                
                if self.log {
                    self.log(apiRequest, data)
                }
            }.resume()
        }
    }
    
    private func log(_ apiRequest: APIRequest, _ data: Data?) {
        print(apiRequest.method.rawValue+" "+apiRequest.url.absoluteString)
        print("Authorization: "+(apiRequest.authorization.headerValue() ?? ""))
        guard let data = data else { return }
        if let data = try? JSONSerialization.jsonObject(with: data) {
            print(data)
        }
    }
}
