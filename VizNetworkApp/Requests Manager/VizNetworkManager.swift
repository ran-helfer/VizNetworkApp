//
//  VizNetworkManager.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 29/07/2021.
//
import Foundation

typealias VizNetworkManagerTaskID = Int

class VizNetworkManager {
    
    private let operationQueue = OperationQueue()
    private static let defaultQueueConcurrentOperations = 5
    private let SuccessRangeOfStatusCodes: ClosedRange<Int> = (200...299)

    init(maxConcurent: Int = defaultQueueConcurrentOperations) {
        operationQueue.maxConcurrentOperationCount = maxConcurent
    }
    
    func addApiRequest<T>(for resource: T,
                          completionDispatchQueue: DispatchQueue? = nil,
                          completion: @escaping (Result<T.ModelType, Error>) -> Void)
    
                                                        -> VizNetworkManagerTaskID?
                                                        where T : VizApiResource {
        
        let request = VizApiNetworkRequest(apiResource: resource)
        let dataTask = request.execute(withCompletion: completion)

        let operation = VizHttpNetworkBlockOperation()
        operation.taskIdentifier = dataTask?.taskIdentifier
        
        /*****************************************************/
        /* What currently looks - completion does not happen */
        /*****************************************************/
                
        operation.addExecutionBlock { 
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
        operationQueue.addOperation(operation)
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

class VizHttpNetworkBlockOperation: BlockOperation {
    var taskIdentifier: Int?
}
