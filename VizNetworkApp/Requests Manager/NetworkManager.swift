//
//  NetworkManager.swift
//  NetworkApp
//
//  Created by Ran Helfer on 29/07/2021.
//
import Foundation

enum NetworkError: Error {
    case cannotDecodeContentData
    case unknown
    case cancelled
    case badURL
    
    func errorDescription() -> String {
        switch self {
        case .cannotDecodeContentData:
            return "cannotDecodeContentData"
        case .unknown:
            return "unknown"
        case .cancelled:
            return "cancelled"
        case .badURL:
            return "badURL"
        }
    }
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let operationQueue = OperationQueue()
    private static let defaultQueueConcurrentOperations = 5
    private let SuccessRangeOfStatusCodes: ClosedRange<Int> = (200...299)

    private init(maxConcurent: Int = defaultQueueConcurrentOperations) {
        operationQueue.maxConcurrentOperationCount = maxConcurent
    }
    
    func load<ModelType: Decodable>(_ request: URLRequest,
                                    dispatchQueue: DispatchQueue = .global(),
                                    responseModelType: ModelType.Type,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> String {
        let operation = HttpNetworkBlockOperation(id: UUID().uuidString)
        operation.addExecutionBlock { [unowned operation] in
            guard operation.isCancelled == false else {
                return
            }
            let group = DispatchGroup()
            group.enter()
            
            let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                NetworkManager.shared.handleRequestResponse(data: data,
                                                            responseModel: responseModelType,
                                                            response: response,
                                                            error: error) { result in
                    guard operation.isCancelled == false else {
                        completion(.failure(NetworkError.cancelled))
                        group.leave()
                        return
                    }
                    completion(result)
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
    
    func load<ModelType: Decodable>(_ url: URL,
                         responseModelType: ModelType.Type,
                         completion: @escaping (Result<ModelType, Error>) -> Void) -> String {
        let request = URLRequest(url: url)
        return load(request, responseModelType: responseModelType, completion: completion)
    }
    
    func cancelAllTasks() {
        operationQueue.cancelAllOperations()
    }
    
    func cancelDataTask(taskIdentifier: String) {
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
        guard let data = data,
              let value =  try? JSONDecoder().decode(responseModel, from: data) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.cannotDecodeContentData))
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
