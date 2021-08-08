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
    var usersList: UsersList?
    let reuseIdentifier = "MyUITableViewCellreuseIdentifier"
    var manager = VizNetworkManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        getRequest(1)
    }
    
    @IBAction func getRequest(_ sender: Any) {
        _ = manager.addApiRequest(for: RemoteGetResource()) { [weak self] result in
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
    
    @IBAction func postRequest(_ sender: Any) {
        
        _ = manager.addApiRequest(for: RemotePostResource.getPostObject()) { [weak self] result in
            switch result {
            case .success(let object):
                print("object: \(object)")
                self?.getRequest(1)
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
        
        /* Assemble URL */
        var deleteResource = RemoteDeleteResource()
        deleteResource.path = (deleteResource.path ?? "") + "/\(userId)" // You can insert a fake delete here
        
        _ = manager.addApiRequest(for: deleteResource) { [weak self] result in
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
}

