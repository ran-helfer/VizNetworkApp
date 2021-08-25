//
//  NetworkRequest.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 10/08/2021.
//

import Foundation

typealias DataTaskStringIdentifier = String

protocol NetworkRequest: AnyObject {
    associatedtype resource: ApiResource
    
    func execute(completion: @escaping (Result<resource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier
}
