//
//  Requests.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 04/08/2021.
//

import Foundation

/* at terminal run
    python api_endpoints.py
 
    if you have any issues try to first run:
    pip install flask
    pip install flask_restful
*/

/***********/
/**  GET  **/
/***********/

struct RemoteGetResource: VizHttpApiResource {
    var headers: [String : String]? =
        ["Content-Type" : "application/json"]

    var queryItems: [URLQueryItem]?
    
    typealias ModelType = UsersList
    typealias InputModelType = NoInputModelTypeDefault
    
    var basePath: String {
        "http://127.0.0.1:5000"
    }
    
    var path: String? = "/users"
    
    var method: VizHttpMethod {
        .get(nil, nil)
    }
}

/***********/
/**  POST **/
/***********/

struct RemotePostResource: VizHttpApiResource {
    var headers: [String : String]? =
        ["Content-Type" : "application/json"]
    
    var queryItems: [URLQueryItem]?
    var dynamicPathComponent: String?

    var method: VizHttpMethod
    
    typealias ModelType = UserObject
    typealias InputModelType = UserObject

    var basePath: String {
        "http://127.0.0.1:5000"
    }
    
    var path: String? = "/users"
    
    static func getPostObject() -> RemotePostResource {
        let randomNumber = Int.random(in: 1...1000)
        let randomNameLength = Int.random(in: 1...5)
        let randomCityLength = Int.random(in: 1...7)

        let object = UserObject(userId: "\(randomNumber)",
                                name: randomAlphaNumericString(length: randomNameLength),
                                city: randomAlphaNumericString(length: randomCityLength))
        return RemotePostResource(method: .post(nil, object))
    }
    
    /******************/
    /* Utilities ******/
    /******************/

    static func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""

        for _ in 0 ..< length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }

        return randomString
    }
}

/*************/
/**  DELETE **/
/*************/

struct RemoteDeleteResource: VizHttpApiResource {
    var headers: [String : String]? =
        ["Content-Type" : "application/json"]
    
    var queryItems: [URLQueryItem]?

    var method: VizHttpMethod {
        .delete(nil, nil)
    }
    
    typealias ModelType = UserObject
    typealias InputModelType = NoInputModelTypeDefault

    var basePath: String {
        "http://127.0.0.1:5000"
    }
    
    var path: String? = "/users"
}
