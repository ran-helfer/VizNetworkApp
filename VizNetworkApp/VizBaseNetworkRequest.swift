//
//  VizBaseNetworkRequest.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

// dummy error enum
enum VizBaseNetworkRequestError: Error {
    case failed
}

protocol VizBaseNetworkRequest: AnyObject {
    associatedtype ModelType
    func decodeData(_ data: Data) -> ModelType?
    func execute(withCompletion completion: @escaping (Result<ModelType, Error>) -> Void)
}

extension VizBaseNetworkRequest {
    func load(_ request: URLRequest, withCompletion completion: @escaping (Result<ModelType, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, let value = self?.decodeData(data) else {
                DispatchQueue.main.async { completion(.failure(VizBaseNetworkRequestError.failed))
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
            let decodedValue = self?.decodeData(data ?? Data())
            guard let data = data, let value = self?.decodeData(data) else {
                DispatchQueue.main.async { completion(.failure(VizBaseNetworkRequestError.failed))
                }
                return
            }
            DispatchQueue.main.async { completion(.success(value)) }
        }
        task.resume()
    }
}



