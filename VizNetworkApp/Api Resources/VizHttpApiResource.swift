//
//  VizHttpApiResource.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

/* VizHttpApiResource describes how a basic HTTP network request remote resource should be addressed - on top of VizApiResource */

protocol VizHttpApiResource: VizApiResource {
    /* If no input model is needed - default to NoInputModelTypeDefault */
    associatedtype InputModelType: Encodable

    var method: VizHttpMethod { get }
    var headers: [String: String]? { get }
    mutating func urlRequest() -> URLRequest?
    
    /* If needs to set timeout - implement this protocol method.
       Otherwise default timeout will be used */
    var timeout: TimeInterval { get }
}

extension VizHttpApiResource {
    mutating func urlRequest() -> URLRequest? {
        var request = URLRequest(url: url)

        switch method {
        case .post, .put:
            request.httpBody = httpBody
        case let .get(queryItems, _):
            self.queryItems = queryItems
            request = URLRequest(url: url)
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
        guard let encodedBody = method.encodedInput() as? Self.InputModelType
            else {
            return nil
        }
        let helper = EncodeHelper<InputModelType>(data: encodedBody)
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
    
    /* The second parameter Encodable, is the InputModelType */
    case get([URLQueryItem]?,
             Encodable?)
    case put([URLQueryItem]?,
             Encodable?)
    case post([URLQueryItem]?,
              Encodable?)
    case delete([URLQueryItem]?,
                Encodable?)
    case head([URLQueryItem]?,
              Encodable?)

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
        case .post(_, let input),
             .put(_,  let input): do {
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

struct NoInputModelTypeDefault: Encodable {}
