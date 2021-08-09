//
//  Models.swift
//  NetworkApp
//
//  Created by Ran Helfer on 28/07/2021.
//

import Foundation

struct UserObject: Codable {
    let userId: String?
    let name: String?
    let city: String?
}

struct UsersList: Codable {
    let users: [UserObject]?
}

struct ResponsePostUsersObject: Codable {
    let value: [UserObject]?
}


//base path "https://reqbin.com"
//"/echo/get/json/page/2"


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

/* Get request */
struct SingularObject: Codable {
    let id: Int
    let name: String
    let price: Int
}

struct LinksData: Codable {
    let next: String
    let prev: String
}

struct ResponseObjectList: Codable {
    let items: [SingularObject]
    let limit: Int?
    let links: LinksData?
}
