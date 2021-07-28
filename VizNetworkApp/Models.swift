//
//  Models.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 28/07/2021.
//

import Foundation

/* Get request */
struct SingularObject: Decodable {
    let id: Int
    let name: String
    let price: Int
}

struct LinksData: Decodable {
    let next: String
    let prev: String
}

struct ResponseObjectList: Decodable {
    let items: [SingularObject]
    let limit: Int?
    let links: LinksData?
}


/* Post request */
struct PostObject: Codable {
    let Id: Int
    let Customer: String
    let Quantity: Int
    let Price: Double
}

struct PostResponseObject: Codable {
    let success: Bool
}
