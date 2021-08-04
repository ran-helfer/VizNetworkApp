//
//  VizNetworkManager.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 29/07/2021.
//

import Foundation

struct VizNetworkManager {
    
    private let operationQueue = OperationQueue()
    private static let defaultQueueConcurrentOperations = 5

    init(maxConcurent: Int = Self.defaultQueueConcurrentOperations) {
        operationQueue.maxConcurrentOperationCount = maxConcurent
    }
    
    mutating func addApiRequest<T>(with structure: T) -> Int? where T : VizApiResource {
        //        let operationWrapper = VizNetworkBlockOperationWrapper<T>(vizHttpRequest: request,
        //                                                                  completionDispatchQueue: completionQueue,
        //                                                                  completion: completion)
        //        let blockOperation = operationWrapper.operationWithDataTask()
        //        operationQueue.addOperation(blockOperation)
        //        return blockOperation.taskIdentifier
        
        return 0
    }
    
    func cancelAllTasks() {
        operationQueue.cancelAllOperations()
    }
    
    func cancelDataTask(taskIdentifier: Int) {
//        let operation = operationQueue.operations.first { operation in
//            if let operation = operation as? VizHttpNetworkBlockOperation, operation.taskIdentifier == taskIdentifier {
//                return true
//            }
//            return false
//        }
//        operation?.cancel()
    }
}
