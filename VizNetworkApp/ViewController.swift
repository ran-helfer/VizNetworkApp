//
//  ViewController.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import UIKit

class ViewController: UIViewController {

    /* need to keep reference or decoding won't happen since instance is being released when makeRequest block is finished */
    var request: VizApiNetworkRequest<SomeListRequestStructure>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeRequest(1)
    }
    
    @IBAction func makeRequest(_ sender: Any) {
        request = VizApiNetworkRequest(requestStructure: SomeListRequestStructure())
        request?.execute { result in
            switch result {
            case .success(let object):
                print("object: \(object)")
            case .failure(let error):
                print(error)
            }
        }
    }
}

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

struct SomeListRequestStructure: VizHttpRequestStructure {
    var basePath: String {
        "https://reqbin.com"
    }
    
    var queryItems: [URLQueryItem]?
    
    var method: VizHttpMethod {
        .get(nil)
    }

    var headers: [String : String]? {
        nil
    }

    typealias ModelType = ResponseObjectList
    var path: String {
        "/echo/get/json/page/2"
    }
}
