//
//  VizApiResource.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

/* VizApiResource describes how a basic remote api resource should be addressed.
    basePath, path, queryItems and usually an API request involves an associated return type which we want to decode to an object */

protocol VizApiResource {
    associatedtype ModelType: Codable
    var path: String { get }
    var basePath: String { get }
    var queryItems: [URLQueryItem]? { get set }
}

extension VizApiResource {
    var url: URL {
        var components = URLComponents(string:basePath)
        components?.path = path
        components?.queryItems = queryItems
        guard let url = components?.url else {
            assertionFailure("could not build url")
            return URL(fileURLWithPath: "")
        }
        return url
    }

}
