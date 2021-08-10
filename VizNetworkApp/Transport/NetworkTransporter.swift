//
//  NetworkTransporter.swift
//  NetworkApp
//
//  Created by Ran Helfer on 29/07/2021.
//
import Foundation
import UIKit

enum NetworkError: Error {
    case urlError(URLError)
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
                                    responseModelType: ModelType.Type,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        /* uuidString is being used for:
           1) Tracking operation in case operation needs to be cancelled
           2) Start and end background tasks */
        let uuidString = UUID().uuidString
        
        startBackgroundTask(uuidString: uuidString)
        
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
                        completion(.failure(NetworkError.urlError(URLError(.cancelled))))
                        group.leave()
                        return
                    }
                    completion(result)
                    self.endBackgroundTask(uuidString: uuidString)
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
    
    func load<ModelType: Decodable>(_ url: URL,
                         responseModelType: ModelType.Type,
                         completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        let request = URLRequest(url: url)
        return load(request, responseModelType: responseModelType, completion: completion)
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
                completion(.failure(NetworkError.urlError(URLError(.unknown))))
            }
            return
        }
        
        if let r = response as? HTTPURLResponse {
            print(r.statusCode)
            print(r)
        }
        guard let data = data,
              let value =  try? JSONDecoder().decode(responseModel, from: data) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlError(URLError(.cannotDecodeContentData))))
            }
            return
        }
        DispatchQueue.main.async { completion(.success(value))}
    }
}

class HttpNetworkBlockOperation: BlockOperation {
    var taskIdentifier: String
    init(id: String) {
        self.taskIdentifier = id
        super.init()
    }
}
