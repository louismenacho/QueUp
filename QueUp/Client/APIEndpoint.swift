//
//  APIEndpoint.swift
//  QueUp
//
//  Created by Louis Menacho on 5/7/22.
//

import Foundation

protocol APIEndpoint {
    var baseURL: String { get }
    var request: APIRequest { get }
}
