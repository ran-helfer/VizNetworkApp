//
//  ViewController.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import UIKit

class ViewController: UIViewController {

    /* need to keep reference or decoding won't happen since instance is being released when makeRequest block is finished */
    var request: VizApiNetworkRequest<SomeRemoteObjectRequestStructure>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeRequest(1)
    }
    
    @IBAction func makeRequest(_ sender: Any) {
        request = VizApiNetworkRequest(requestStructure: SomeRemoteObjectRequestStructure())
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

struct SomeRemoteObjectRequestStructure: VizHttpRequestStructure {
    
    typealias ModelType = ResponseObjectList

    var basePath: String {
        "https://reqbin.com"
    }
    
    var path: String {
        "/echo/get/json/page/2"
    }
    
    var method: VizHttpMethod {
        .get(nil)
    }
}
