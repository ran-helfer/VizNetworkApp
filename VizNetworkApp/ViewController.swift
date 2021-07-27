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

        let request = VizApiNetworkRequest(resource: ListResource())
        request.execute { result in
            switch result {
            case .success(let patients):
                print("patients: \(patients)")
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension VizHttpRequestStructure {
    var basePath: String {
        "https://reqbin.com/echo/get/json/page"
    }
}

struct ResponseObject: Decodable {
    let id: Int
    let name: String
    let price: Int
}

struct ListResource: VizHttpRequestStructure {
    var queryItems: [URLQueryItem]?
    
    var method: HTTPMethod {
        .get
    }

    var headers: [String : String]? {
        ["content-type": "json"]
    }

    typealias ModelType = [ResponseObject]
    var path: String {
        "/2"
    }
}
