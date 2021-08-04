//
//  VizBaseNetworkRequest.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

protocol VizBaseNetworkRequest: AnyObject {
    associatedtype ModelType
    func decodeData(_ data: Data) -> ModelType?
    func execute(withCompletion completion: @escaping (Result<ModelType, Error>) -> Void) -> URLSessionDataTask?
}

extension VizBaseNetworkRequest {
    func load(_ request: URLRequest,
              withCompletion completion: @escaping (Result<ModelType, Error>) -> Void) -> URLSessionDataTask? {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let weakSelf = self else {return}
            weakSelf.handleRequestResponse(data: data,
                                           response: response,
                                           error: error,
                                           completion: completion)
        }
        task.resume()
        return task
    }
    
    func load(_ url: URL, withCompletion completion: @escaping (Result<ModelType, Error>) -> Void) -> URLSessionDataTask? {
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response , error) -> Void in
            guard let weakSelf = self else {return}
            weakSelf.handleRequestResponse(data: data,
                                           response: response,
                                           error: error,
                                           completion: completion)
        }
        task.resume()
        return task
    }
    
    private func handleRequestResponse(data:Data?,
                                       response:Any?,
                                       error:Error?,
                                       completion: @escaping (Result<ModelType, Error>) -> Void) {
        guard error == nil else {
            if let err = error {
                completion(.failure(err))
            } else {
                completion(.failure(VizBaseNetworkRequestError.recievedErrorFromServer))
            }
            return
        }
        
        if let r = response as? HTTPURLResponse {
            print(r.statusCode)
            print(r)
        }
        guard let data = data,
              let value =  self.decodeData(data) else {
            DispatchQueue.main.async {
                completion(.failure(VizBaseNetworkRequestError.failed))
            }
            return
        }
        DispatchQueue.main.async { completion(.success(value))}
    }
}

enum VizBaseNetworkRequestError: Error {
    case failed
    case recievedErrorFromServer
}
