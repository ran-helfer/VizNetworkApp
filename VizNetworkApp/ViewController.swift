//
//  ViewController.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        makeRequest(1)
    }
    
    @IBAction func makeRequest(_ sender: Any) {
        let request = VizApiNetworkRequest(resource: SomeListRequestStructure())
        request.execute { result in
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
    
    func requestedTimeout() -> TimeInterval? {
        nil
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
