//
//  ViewController.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import UIKit

class ViewController: UIViewController {

    /* need to keep reference or decoding won't happen since instance is being released when makeRequest block is finished */
    var request: VizHttpNetworkRequest<SomeRemoteObjectRequestStructure>?
        
    @IBAction func makeRequest(_ sender: Any) {
        request = VizHttpNetworkRequest(requestStructure: SomeRemoteObjectRequestStructure())
        _ = request?.execute { result in
            switch result {
            case .success(let object):
                print("object: \(object)")
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct SomeRemoteObjectRequestStructure: VizHttpRequestStructure {
    
    /* run python api_endpoints.py  in terminal so you can check up the server */
    
    typealias ModelType = ResponseUsersObjectList

    var basePath: String {
        "http://127.0.0.1:5000"
        //"https://reqbin.com"
    }
    
    var path: String {
        //"/echo/get/json/page/2"
        "/users"
    }
    
    var method: VizHttpMethod {
        .get(nil)
    }
}

/*
struct SomeRemoteObjectPOSTRequestStructure: VizHttpRequestStructure {
    
    typealias ModelType = PostResponseObject

    var basePath: String {
        "https://reqbin.com"
    }
    
    var path: String {
        "/echo/post/json/"
    }
    
    let object = PostObject(Id: 1, Customer: "Ran", Quantity: 1, Price: 19.0)
    
    var method: VizHttpMethod {
        .post(object)
    }
}*/

