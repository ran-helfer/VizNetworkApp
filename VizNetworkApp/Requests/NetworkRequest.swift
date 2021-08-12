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
              completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier
    
    func load(_ url: URL,
              completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier
}
