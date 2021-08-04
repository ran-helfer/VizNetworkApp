//
//  VizApiRequestStructure.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

/* VizApiRequestStructure describes how a basic network request structure should look like.
    basePath, path, queryItems and usually an API request involves an associated return type which we want to decode to an object */
// RODO: VizApiRequestStructure --> VizApiResource
protocol VizApiRequestStructure {
    associatedtype ModelType: Codable
    var path: String { get }
    var basePath: String { get }
    var queryItems: [URLQueryItem]? { get set }
}

extension VizApiRequestStructure {
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
