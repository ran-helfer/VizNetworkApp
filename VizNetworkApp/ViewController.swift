//
//  ViewController.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//
/* resource */

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    /* need to keep reference or decoding won't happen since instance is being released when makeRequest block is finished */
    var request: VizApiNetworkRequest<GetRemoteObjectRequestStructure>?
    var postRequest: VizApiNetworkRequest<PostObjectRequestStructure>?
    var usersList: ResponseUsersObjectList?
    let reuseIdentifier = "MyUITableViewCellreuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let usersList = self.usersList,
              let users = usersList.persons else {
            return 0
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let list = self.usersList,
           let users = list.persons {
            let string = "\(String(describing: users[indexPath.row].userId)) + \(String(describing: users[indexPath.row].name))"
            cell.textLabel?.text = string
        }
        
        return cell
    }
    
    @IBAction func postRequest(_ sender: Any) {
        let randomNumber = Int.random(in: 1...100000000000000)
        let object = UserObject(userId: "\(randomNumber)",
                                name: "someName",
                                city: "someCity")
        let postReq = PostObjectRequestStructure(method: .post(object))
        postRequest = VizApiNetworkRequest(requestStructure: postReq)
        _ = postRequest?.execute(withCompletion: { [weak self]  result in
            switch result {
            case .success(let object):
                print("object: \(object)")
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func getRequest(_ sender: Any) {
        request = VizApiNetworkRequest(requestStructure: GetRemoteObjectRequestStructure())
        _ = request?.execute { [weak self] result in
            switch result {
            case .success(let object):
                print("object: \(object)")
                self?.usersList = object
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func deleteRequest(_ sender: Any) {
    }
    
    @IBAction func putRequest(_ sender: Any) {
    }
    
}

struct GetRemoteObjectRequestStructure: VizHttpApiResource {
    var headers: [String : String]?
    
    var queryItems: [URLQueryItem]?
    
    
    /* at terminal run
        python api_endpoints.py
    */
    
    typealias ModelType = ResponseUsersObjectList

    var basePath: String {
        "http://127.0.0.1:5000"
    }
    
    var path: String {
        "/users"
    }
    
    var method: VizHttpMethod {
        .get(nil)
    }
}

struct PostObjectRequestStructure: VizHttpApiResource {
    var headers: [String : String]? =
        ["Content-Type" : "application/json"]
    
    var queryItems: [URLQueryItem]?
    
    var method: VizHttpMethod
    
    
    /* at terminal run
        python api_endpoints.py
    */
    
    typealias ModelType = UserObject

    var basePath: String {
        "http://127.0.0.1:5000"
    }
    
    var path: String {
        "/users"
    }
}


/*
struct SomeRemoteObjectPOSTRequestStructure: VizHttpApiResource {
    
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

