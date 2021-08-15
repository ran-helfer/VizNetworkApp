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
                                    onBackground: Bool,
                                    responseModelType: ModelType.Type,
                                    completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier
}

extension NetworkTransport {
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
