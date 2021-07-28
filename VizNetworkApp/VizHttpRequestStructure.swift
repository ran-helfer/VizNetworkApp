//
//  VizHttpRequestStructure.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

enum VizHttpMethod: Equatable {
    static func == (lhs: VizHttpMethod, rhs: VizHttpMethod) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }
        return true
    }
    
    case get([URLQueryItem]?)
    case put(Any?)
    case post(Any?)
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
    
    func requestInputDataAsData() -> Data? {
        switch self {
        case .post(let input), .put(let input): do {
            if let input = input as? Decodable {
                return try? JSONSerialization.data(withJSONObject: input)
            }
            return nil
        }
        case .get: return nil
        case .delete: return nil
        case .head: return nil
        }
    }
        
    func defaultTimeout() -> TimeInterval {
        15
    }
}

protocol VizHttpRequestStructure: VizApiRequestStructure {
    var method: VizHttpMethod { get }
    var headers: [String: String]? { get }
    // files...
    var urlRequest: URLRequest { get }
    
    /* If needs to set timeout - implement this protocol method. Otherwise default timeout will be used */
    func requestedTimeout() -> TimeInterval?
}

extension VizHttpRequestStructure {
    var urlRequest: URLRequest {
        guard let url = URL(string: path) else {
            assertionFailure("could not assemble url at VizHTTPNetworkRequest")
            return URLRequest(url: URL(string: "")!)
        }
        var request = URLRequest(url: url)

        switch method {
        case .post, .put:
            request.httpBody = method.requestInputDataAsData()
        case let .get(queryItems):
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let queryItems = queryItems {
                components?.queryItems = queryItems
            }
            guard let url = components?.url else {
                preconditionFailure("Couldn't create a url from components...")
            }
            request = URLRequest(url: url)
        default:
            break
        }
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.name
        request.timeoutInterval = requestedTimeout() ?? method.defaultTimeout()
        
        return request
    }
    
    func requestedTimeout() -> TimeInterval? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var headers: [String : String]? {
        nil
    }
}
