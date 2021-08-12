//
//  ViewController.swift
//  NetworkApp
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
    //var backgroundTaskId: UIBackgroundTaskIdentifier? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        getRequest(1)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @IBAction func getRequest(_ sender: Any) {
        let request = ApiNetworkRequest(apiResource: RemoteGetResource())
        _ = request.execute { [weak self] result in
            switch result {
            case .success(let object):
                self?.usersList = object
                self?.tableView.reloadData()
            case .failure(let error):
                if let error = error as? NetworkError {
                    print(error.errorDescription())
                } else {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func postRequest(_ sender: Any) {
        let request = ApiNetworkRequest(apiResource: RemotePostResource.getPostObject())
        _ = request.execute { [weak self] result in
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
        let request = ApiNetworkRequest(apiResource: deleteResource)
        _ = request.execute { [weak self] result in
            switch result {
            case .success(let object):
                print("object: \(object)")
                self?.getRequest(1)
            case .failure(let error):
                print(error)
            }
        }
        
    }

    
    
    /* Delta time is about 26-27 seconds */
    
//    @objc func appMovedToBackground() {
//        let startTime = Date()
//        print("start time is now \(startTime)")
//        self.backgroundTaskId = UIApplication.shared.beginBackgroundTask(
//            withName: "test demon",
//            expirationHandler: {
//              let endTime = Date()
//                print("end time is now \(endTime)")
//                print("delta time = \(endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970)")
//                UIApplication.shared.endBackgroundTask(self.backgroundTaskId!)
//
//          })
//
//    }
    
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

