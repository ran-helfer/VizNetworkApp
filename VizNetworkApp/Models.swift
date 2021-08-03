//
//  Models.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 28/07/2021.
//

import Foundation

/*
 local server:
 
 userId,name,city,locations
 a1b,Joe,Paris,"['0001', '0002', '0008']"
 a2c,Jenny,London,"['0003', '0004']"
 b1b,Jack,London,"['0003', '0005']"
 b2c,Jill,Berlin,"['0006', '0007']"

locationId,name,rating
1,Café de Flore,4.0
2,Café Tabac,4.6
3,Rosslyn Coffee,4.8
4,Three Wheels Coffee,4.6
5,Roasting Plant Coffee,4.4
6,Distrikt coffee,4.4
7,Westberlin,4.4
*/

struct UserObject: Codable {
    let userId: String?
    let name: String?
    let city: String?
    //let locations: String?
}

struct ResponseUsersObjectList: Decodable {
    let persons: [UserObject]?
}

struct ResponsePostUsersObject: Decodable {
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
