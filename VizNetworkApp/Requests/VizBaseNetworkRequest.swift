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
    func execute(withCompletion completion: @escaping (Result<ModelType, Error>) -> Void)
}

extension VizBaseNetworkRequest {
    func load(_ request: URLRequest, withCompletion completion: @escaping (Result<ModelType, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil else {
                if let err = error {
                    completion(.failure(err))
                } else {
                    completion(.failure(VizBaseNetworkRequestError.recievedErrorFromServer))
                }
                return
            }
            
            guard let weakSelf = self,
                  let data = data,
                  let value =  weakSelf.decodeData(data) else {
                DispatchQueue.main.async {
                    completion(.failure(VizBaseNetworkRequestError.failed))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(value))
            }
        }
        task.resume()
    }
    
    func load(_ url: URL, withCompletion completion: @escaping (Result<ModelType, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response , error) -> Void in
            guard error == nil else {
                if let err = error {
                    completion(.failure(err))
                } else {
                    completion(.failure(VizBaseNetworkRequestError.recievedErrorFromServer))
                }
                return
            }
            
            print(response as Any)
            guard let weakSelf = self,
                  let data = data,
                  let value =  weakSelf.decodeData(data) else {
                DispatchQueue.main.async {
                    completion(.failure(VizBaseNetworkRequestError.failed))
                }
                return
            }
            DispatchQueue.main.async { completion(.success(value)) }
        }
        task.resume()
    }
}

enum VizBaseNetworkRequestError: Error {
    case failed
    case recievedErrorFromServer
}
