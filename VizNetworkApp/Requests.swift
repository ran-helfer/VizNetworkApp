//
//  Requests.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 04/08/2021.
//

import Foundation

/***********/
/**  GET  **/
/***********/

struct RemoteGetResource: VizHttpApiResource {
    var headers: [String : String]? =
        ["Content-Type" : "application/json"]

    var queryItems: [URLQueryItem]?

    /* at terminal run
        python api_endpoints.py
    */
    
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
    
    
    /* at terminal run
        python api_endpoints.py
    */
    
    typealias ModelType = UserObject
    typealias InputModelType = UserObject

    var basePath: String {
        "http://127.0.0.1:5000"
    }
    
    var path: String? = "/users"
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
    
    /* at terminal run
        python api_endpoints.py
    */
    
    typealias ModelType = UserObject
    typealias InputModelType = NoInputModelTypeDefault

    var basePath: String {
        "http://127.0.0.1:5000"
    }
    
    var path: String? = "/users"
}
