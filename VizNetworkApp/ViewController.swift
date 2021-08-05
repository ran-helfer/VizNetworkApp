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
    var deleteRequest: VizApiNetworkRequest<RemoteDeleteResource>?
    var usersList: UsersList?
    let reuseIdentifier = "MyUITableViewCellreuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        getRequest(1)
    }
    
    @IBAction func postRequest(_ sender: Any) {
        let randomNumber = Int.random(in: 1...1000)
        let randomNameLength = Int.random(in: 1...5)
        let randomCityLength = Int.random(in: 1...7)

        let object = UserObject(userId: "\(randomNumber)",
                                name: randomAlphaNumericString(length: randomNameLength),
                                city: randomAlphaNumericString(length: randomCityLength))
        let postReq = RemotePostResource(method: .post(object))
        postRequest = VizApiNetworkRequest(apiResource: postReq)
        _ = postRequest?.execute(withCompletion: { [weak self]  result in
            switch result {
            case .success(let object):
                print("object: \(object)")
                self?.getRequest(1)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func getRequest(_ sender: Any) {
        request = VizApiNetworkRequest(apiResource: RemoteGetResource())
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
        guard let list = self.usersList,
           let users = list.users,
           users.count > 0,
           let userId = users.last?.userId?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        let deletePath = "/\(userId)" // You can insert a fake delete here

        var deleteResource = RemoteDeleteResource()
        deleteResource.dynamicPathComponent = deletePath
        deleteRequest = VizApiNetworkRequest(apiResource: deleteResource)
        _ = deleteRequest?.execute { [weak self] result in
            switch result {
            case .success(let object):
                print("object: \(object)")
                self?.getRequest(1)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    @IBAction func putRequest(_ sender: Any) {
    }
    
    /**********************/
    /*** Table View  ******/
    /**********************/
    
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
    
    /******************/
    /* Utilities ******/
    /******************/

    private func randomAlphaNumericString(length: Int) -> String {
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

