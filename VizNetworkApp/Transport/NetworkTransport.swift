//
//  NetworkTransport.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 09/08/2021.
//

import Foundation

typealias DataTaskStringIdentifier = String

protocol NetworkTransport {
    func load<ModelType: Decodable>(_ request: URLRequest,
                                    dispatchQueue: DispatchQueue,
                                    onBackground: Bool,
                                    responseModelType: ModelType.Type,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier
    func decode<ModelType: Decodable>(_ data: Data) throws -> ModelType
}

extension NetworkTransport {
    
    func decode<ModelType: Decodable>(_ data: Data) throws -> ModelType {
        try JSONDecoder().decode(ModelType.self, from: data)
    }
    
    func load<ModelType: Decodable>(_ request: URLRequest,
                                    dispatchQueue: DispatchQueue = .main,
                                    onBackground: Bool = false,
                                    responseModelType: ModelType.Type = ModelType.self,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        /**************************/
        /* Default implementation */
        /**************************/
        NetworkTransporter.shared.load(request, dispatchQueue: dispatchQueue, onBackground: onBackground, responseModelType: responseModelType, completion: completion)
    }
    
    
    func load<ModelType: Decodable>(_ request: URLRequest,
                                    onBackground: Bool = false,
                                    responseModelType: ModelType.Type,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        /* We cannot declare default argument in protocol decleration */
        load(request,
             dispatchQueue: .global(),
             onBackground: onBackground,
             responseModelType: responseModelType,
             completion: completion)
    }
    
    func load<ModelType: Decodable>(_ url: URL,
                                    onBackground: Bool,
                                    responseModelType: ModelType.Type,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        load(URLRequest(url: url),
             onBackground: onBackground,
             responseModelType: responseModelType,
             completion: completion)
    }
}
