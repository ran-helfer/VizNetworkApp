//
//  VizHttpApiResource.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

/* VizHttpApiResource describes how a basic HTTP network request structure should look like - on top of VizApiResource */

protocol VizHttpApiResource: VizApiResource {
    var method: VizHttpMethod { get }
    var headers: [String: String]? { get }
    mutating func urlRequest() -> URLRequest?
    
    var dynamicPathComponent: String? { get set }

    /* If needs to set timeout - implement this protocol method.
       Otherwise default timeout will be used */
    var timeout: TimeInterval { get }
}

extension VizHttpApiResource {
    mutating func urlRequest() -> URLRequest? {
        var requestURL = url
        
        print(requestURL.path)
        if let additionalPath = dynamicPathComponent {
            var components = URLComponents(string:basePath)
            components?.path = path + additionalPath
            components?.queryItems = queryItems
            if let url = components?.url  {
                requestURL = url
            }
        }
        print(requestURL.path)

        var request = URLRequest(url: requestURL)

        switch method {
        case .post, .put:
            request.httpBody = httpBody
        case let .get(queryItems):
            self.queryItems = queryItems
            request = URLRequest(url: requestURL)
        default:
            break
        }
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.name
        request.timeoutInterval = timeout
        
        if let headers = self.headers {
            for  header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        print("hitting url \(String(describing: request.url))")
        return request
    }
    
    var timeout: TimeInterval {
        60
    }
    
    private var httpBody: Data? {
        guard let encodedBody = method.encodedInput() as? Self.ModelType else {
            return nil
        }
        let helper = EncodeHelper<ModelType>(data: encodedBody)
        let jsonData = helper.encode()
        let jsonString = String(data: jsonData ?? Data(), encoding: .utf8)
        print(jsonString ?? "")
        return jsonData
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
    
    func encodedInput() -> Encodable? {
        switch self {
        case .post(let input),
             .put(let input): do {
            return input
        }
        default:
            return nil
        }
    }
}

struct EncodeHelper<T: Encodable> {
    let data: T?
    func encode() -> Data? {
        return try? JSONEncoder().encode(data)
    }
}
