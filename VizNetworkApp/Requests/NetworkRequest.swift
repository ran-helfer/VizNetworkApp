//
//  NetworkRequest.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 10/08/2021.
//

import Foundation

typealias DataTaskStringIdentifier = String

protocol NetworkRequest: AnyObject {
    
    associatedtype ModelType: Decodable
    
    func load(_ request: URLRequest,
              useBackgroundTask: Bool,
              completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier
}

extension NetworkRequest {
    func load(_ request: URLRequest,
              useBackgroundTask: Bool = false,
              completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        load(request, useBackgroundTask: useBackgroundTask, completion: completion)
    }
    
    func load(_ url: URL,
              useBackgroundTask: Bool = false,
              completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        load(URLRequest(url: url), useBackgroundTask: useBackgroundTask, completion: completion)
    }
}
