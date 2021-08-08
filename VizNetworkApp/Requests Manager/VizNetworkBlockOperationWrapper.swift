//
//  VizNetworkBlockOperationWrapper.swift
//  VizAINotify
//
//  Created by Ran Helfer on 22/06/2021.
//  Copyright © 2021 viz. All rights reserved.
//

import Foundation

enum VizNetworkOperationError: String, Error {
    case noResponseData
    case badMimeType
    case badStatusCode
}

class VizHttpNetworkBlockOperation: BlockOperation {
    var taskIdentifier: Int?
}

class VizNetworkBlockOperationWrapper<Type: VizApiResource> {
    
    let requestType: Type
    var completionDispatchQueue: DispatchQueue?
    let completion: (Result<Type.ModelType, Error>) -> Void
    private let SuccessRangeOfStatusCodes: ClosedRange<Int> = (200...299)

    init(requestType: Type,
         completionDispatchQueue: DispatchQueue? = nil,
         completion: @escaping (Result<Type.ModelType, Error>) -> Void) {
        self.requestType = requestType
        self.completionDispatchQueue = completionDispatchQueue
        self.completion = completion
    }
        
    func operationWithDataTask() -> VizHttpNetworkBlockOperation {
        let dataTask = self.dataTask()
        let operation = VizHttpNetworkBlockOperation()
        operation.taskIdentifier = dataTask.taskIdentifier
        operation.addExecutionBlock { [unowned operation] in
            guard !operation.isCancelled else {
                return
            }
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.global().async {
                dataTask.resume()
            }
            group.wait()
        }
        return operation
    }
        
    func dataTask() -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: URL(fileURLWithPath: "dsfdsf"))
    }
    
    private func logErrorsIfNeeded(errors: [Error]) {
        guard errors.count > 0 else {
            return
        }
        for error in errors {
            logError("VizNetworkOperation Error: \(error)",
                     file: #file,
                     function: #function,
                     line: #line)
        }
    }
}
