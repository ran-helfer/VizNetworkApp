//
//  HttpApiResource.swift
//  Network
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

/* HttpApiResource describes how a basic HTTP network request remote resource should be addressed - on top of ApiResource */

protocol HttpApiResource: ApiResource {
    /* If no input model is needed - default to NoInputModelTypeDefault */
    associatedtype InputModelType: Encodable

    var method: HttpMethod { get }
    var headers: [String: String]? { get }
    mutating func urlRequest() -> URLRequest?
    
    /* If needs to set timeout - implement this protocol method.
       Otherwise default timeout will be used */
    var timeout: TimeInterval { get }
}

extension HttpApiResource {
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
        
        if let headers = headers {
            var allHTTPHeaderFields = defaultHeaders()
            allHTTPHeaderFields.merge(headers) {(_,new) in new}
            request.allHTTPHeaderFields = allHTTPHeaderFields
        } else {
            request.allHTTPHeaderFields = defaultHeaders()
        }
        
        request.httpMethod = method.name
        request.timeoutInterval = timeout
        
        if let headers = self.headers {
            for  header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
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
    
    func defaultHeaders() -> [String : String] {
        ["Content-Type" : "application/json"]
        /* Accumulate whatever headers we need here */
    }
}

enum HttpMethod: Equatable {
    static func == (lhs: HttpMethod, rhs: HttpMethod) -> Bool {
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
