//
//  NetworkTransporter.swift
//  NetworkApp
//
//  Created by Ran Helfer on 29/07/2021.
//
import Foundation
import UIKit

enum NetworkError: Error {
    case cannotDecodeContentData(Error)
    case noDataRecieved
    case unknown
    case cancelled
    case transportMissingOnLoad
    case badURL
    
    func errorDescription() -> String {
        switch self {
        case .cannotDecodeContentData(let error):
            return "cannot Decode Content Data " + error.localizedDescription
        case .noDataRecieved:
            return "no Data Recieved"
        case .unknown:
            return "unknown"
        case .cancelled:
            return "cancelled"
        case .transportMissingOnLoad:
            return "transport Missing OnLoad"
        case .badURL:
            return "badURL"
        }
    }
}

class NetworkTransporter: NetworkTransport {
    
    static let shared = NetworkTransporter()
    
    private let operationQueue = OperationQueue()
    private var backgroundTasksIds = [DataTaskStringIdentifier : UIBackgroundTaskIdentifier]()
    private static let defaultQueueConcurrentOperations = 5
    private let SuccessRangeOfStatusCodes: ClosedRange<Int> = (200...299)

    init(maxConcurent: Int = defaultQueueConcurrentOperations) {
        operationQueue.maxConcurrentOperationCount = maxConcurent
    }
    
    func load<ModelType: Decodable>(_ request: URLRequest,
                                    dispatchQueue: DispatchQueue = .global(),
                                    onBackground: Bool = false,
                                    responseModelType: ModelType.Type,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        /* uuidString is being used for:
           1) Tracking operation in case operation needs to be cancelled
           2) Start and end background tasks */
        let uuidString = UUID().uuidString
        
        if onBackground {
            startBackgroundTask(uuidString: uuidString)
        }
        
        let operation = HttpNetworkBlockOperation(id: uuidString)
        operation.addExecutionBlock { [unowned operation] in
            guard operation.isCancelled == false else {
                return
            }
            let group = DispatchGroup()
            group.enter()
            
            let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                NetworkTransporter.shared.handleRequestResponse(data: data,
                                                       responseModel: responseModelType,
                                                       response: response,
                                                       error: error) { result in
                    guard operation.isCancelled == false else {
                        completion(.failure(NetworkError.cancelled))
                        group.leave()
                        return
                    }
                    completion(result)
                    if onBackground {
                        self.endBackgroundTask(uuidString: uuidString)
                    }
                    group.leave()
                }
            }
            dispatchQueue.async {
                dataTask.resume()
            }
           
            group.wait()
        }
        operationQueue.addOperation(operation)
        return operation.taskIdentifier
    }
    
    private func startBackgroundTask(uuidString: String) {
        self.backgroundTasksIds[uuidString] = UIApplication.shared.beginBackgroundTask(
            withName: uuidString,
            expirationHandler: { [weak self] in
                self?.endBackgroundTask(uuidString: uuidString)
        })
    }

    private func endBackgroundTask(uuidString: String) {
        if let taskId = self.backgroundTasksIds[uuidString] {
            UIApplication.shared.endBackgroundTask(taskId)
            self.backgroundTasksIds[uuidString] = nil
        }
    }
    
    func cancelAllTasks() {
        operationQueue.cancelAllOperations()
    }
    
    func cancelDataTask(taskIdentifier: DataTaskStringIdentifier) {
        operationQueue.operations
            .compactMap { $0 as? HttpNetworkBlockOperation }
            .first { $0.taskIdentifier == taskIdentifier }?
            .cancel()
    }
    
    private func handleRequestResponse<ModelType: Decodable>(data:Data?,
                                                  responseModel: ModelType.Type,
                                                  response:Any?,
                                                  error:Error?,
                                                  completion: @escaping (Result<ModelType, Error>) -> Void) {
        guard error == nil else {
            if let err = error {
                completion(.failure(err))
            } else {
                completion(.failure(NetworkError.unknown))
            }
            return
        }
        
        if let r = response as? HTTPURLResponse {
            print(r.statusCode)
            print(r)
        }
        var value: ModelType?
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.noDataRecieved))
            }
            return
        }
        
        do {
            value =  try JSONDecoder().decode(responseModel, from: data)
        } catch let error {
            completion(.failure(NetworkError.cannotDecodeContentData(error)))
            return
        }
        DispatchQueue.main.async { completion(.success(value!))}
    }
}

class HttpNetworkBlockOperation: BlockOperation {
    var taskIdentifier: String
    init(id: String) {
        self.taskIdentifier = id
        super.init()
    }
}
