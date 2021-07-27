//
//  VizHttpRequestStructure.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol VizHttpRequestStructure: VizApiRequestStructure {
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    // files...
    var urlRequest: URLRequest { get }
}

extension VizHttpRequestStructure {
    var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
}
