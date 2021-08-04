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
    var request: VizApiNetworkRequest<RemoteGetResource>?
    var postRequest: VizApiNetworkRequest<RemotePostResource>?
    var usersList: UsersList?
    let reuseIdentifier = "MyUITableViewCellreuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let usersList = self.usersList,
              let users = usersList.users else {
            return 0
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let list = self.usersList,
           let users = list.users {
            if let name = users[indexPath.row].name,
               let city = users[indexPath.row].city,
               let id = users[indexPath.row].userId {
                let string = "\(name) + \(city) -- \(id)"
                cell.textLabel?.text = string
            }
        }
        
        return cell
    }
    
    @IBAction func postRequest(_ sender: Any) {
        let randomNumber = Int.random(in: 1...100000000000000)
        let randomNameLength = Int.random(in: 1...5)
        let randomCityLength = Int.random(in: 1...7)

        let object = UserObject(userId: "\(randomNumber)",
                                name: randomAlphaNumericString(length: randomNameLength),
                                city: randomAlphaNumericString(length: randomCityLength))
        let postReq = RemotePostResource(method: .post(object))
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
        request = VizApiNetworkRequest(requestStructure: RemoteGetResource())
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
    
    func randomAlphaNumericString(length: Int) -> String {
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

struct RemoteGetResource: VizHttpApiResource {
    var headers: [String : String]?
    
    var queryItems: [URLQueryItem]?
    
    
    /* at terminal run
        python api_endpoints.py
    */
    
    typealias ModelType = UsersList

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

struct RemotePostResource: VizHttpApiResource {
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
