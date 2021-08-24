//
//  NetworkTransport.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 09/08/2021.
//

import Foundation

protocol NetworkTransport : AnyObject {
    func load<ModelType: Decodable>(_ request: URLRequest,
                                    dispatchQueue: DispatchQueue,
                                    responseModelType: ModelType.Type,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier
    
    func decode<ModelType: Decodable>(_ data: Data) throws -> ModelType
}

extension NetworkTransport {
    func load<ModelType: Decodable>(_ request: URLRequest,
                                    responseModelType: ModelType.Type,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        /* We cannot declare default argument in protocol decleration */
        load(request, dispatchQueue: .global(), responseModelType: responseModelType, completion: completion)
    }
    
    func load<ModelType: Decodable>(_ url: URL,
                         responseModelType: ModelType.Type,
                         completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        load(URLRequest(url: url), responseModelType: responseModelType, completion: completion)
    }
    
    func decode<ModelType: Decodable>(_ data: Data) throws -> ModelType {
           return try JSONDecoder().decode(ModelType.self, from: data)
    }
}
