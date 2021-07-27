//
//  VizApiRequestStructure.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

protocol VizApiRequestStructure {
    associatedtype ModelType: Decodable
    var path: String { get }
    var basePath: String { get }
    var queryItems: [URLQueryItem]? { get }
}

extension VizApiRequestStructure {
    var url: URL {
        var components = URLComponents(string:basePath)!
        components.path = path
        components.queryItems = queryItems
        return components.url!
    }
}
