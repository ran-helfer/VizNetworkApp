//
//  NetworkRequest.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 10/08/2021.
//

import Foundation

typealias DataTaskStringIdentifier = String

protocol NetworkRequest {
    associatedtype resource: ApiResource
    
    func execute(onBackground: Bool,
                 completion: @escaping (Result<resource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier
}

extension NetworkRequest where resource: HttpApiResource {
    func execute(completion: @escaping (Result<resource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        execute(onBackground: false, completion: completion)
    }
}
