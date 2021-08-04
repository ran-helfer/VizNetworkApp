//
//  VizHttpRequestStructure.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

/* VizHttpRequestStructure describes how a basic HTTP network request structure should look like - on top of VizApiRequestStructure */

protocol VizHttpRequestStructure: VizApiRequestStructure {
    var method: VizHttpMethod { get }
    var headers: [String: String]? { get }
    // files...
    mutating func urlRequest() -> URLRequest?
    
    /* If needs to set timeout - implement this protocol method. Otherwise default timeout will be used */
    var timeout: TimeInterval { get }
}

extension VizHttpRequestStructure {
    mutating func urlRequest() -> URLRequest? {
        var request = URLRequest(url: url)

        switch method {
        case .post, .put:
            request.httpBody = method.httpBody
        case let .get(queryItems):
            self.queryItems = queryItems
            request = URLRequest(url: url)
        default:
            break
        }
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.name
        request.timeoutInterval = timeout
        
        return request
    }
    
    var timeout: TimeInterval {
        60
    }
}

enum VizHttpMethod: Equatable {
    static func == (lhs: VizHttpMethod, rhs: VizHttpMethod) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }
        return true
    }
    
    case get([URLQueryItem]?)
    case put(Encodable?)
    case post(Encodable?)
    case delete
    case head

    var name: String {
        switch self {
        case .get: return "GET"
        case .put: return "PUT"
        case .post: return "POST"
        case .delete: return "DELETE"
        case .head: return "HEAD"
        }
    }
    
    var httpBody:Data? {
        switch self {
        case .post(let input), .put(let input): do {
            if let input = input {
                return try? JSONEncoder().encode(input)
            }
            return nil
        }
        case .get: return nil
        case .delete: return nil
        case .head: return ni
        }
    }
        
    func defaultTimeout() -> TimeInterval {
        15
    }
}

struct EncodeHelper<T: Encodable> {
    let data: T?
    func encode() -> String? {
        guard let jsonData = try? JSONEncoder().encode(data) else {
            return nil
            
        }
        return String(data: jsonData, encoding: .utf8)
    }
}
