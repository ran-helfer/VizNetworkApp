//
//  VizNetworkManager.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 29/07/2021.
//

import Foundation

typealias VizNetworkManagerTaskID = Int

struct VizNetworkManager {
    
    private let operationQueue = OperationQueue()
    private static let defaultQueueConcurrentOperations = 5
    private let SuccessRangeOfStatusCodes: ClosedRange<Int> = (200...299)

    init(maxConcurent: Int = Self.defaultQueueConcurrentOperations) {
        operationQueue.maxConcurrentOperationCount = maxConcurent
    }
    
    mutating func addApiRequest<T>(for resource: T,
                                   completionDispatchQueue: DispatchQueue? = nil,
                                   completion: @escaping (Result<T.ModelType, Error>) -> Void)
                                                        -> VizNetworkManagerTaskID?
                                                        where T : VizApiResource {
        let request = VizApiNetworkRequest(apiResource: resource)
        let dataTask = request.execute(withCompletion: completion)

        let operation = VizHttpNetworkBlockOperation()
        operation.taskIdentifier = dataTask?.taskIdentifier
        
        operation.addExecutionBlock { [unowned operation] in
            guard !operation.isCancelled else {
                return
            }
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.global().async {
                dataTask?.resume()
            }
            group.wait()
        }
        
        return dataTask?.taskIdentifier
    }
    
    func cancelAllTasks() {
        operationQueue.cancelAllOperations()
    }
    
    func cancelDataTask(taskIdentifier: Int) {
        let operation = operationQueue.operations.first { operation in
            if let operation = operation as? VizHttpNetworkBlockOperation, operation.taskIdentifier == taskIdentifier {
                return true
            }
            return false
        }
        operation?.cancel()
    }
}


enum VizNetworkOperationError: String, Error {
    case noResponseData
    case badMimeType
    case badStatusCode
}

class VizHttpNetworkBlockOperation: BlockOperation {
    var taskIdentifier: Int?
}
