//
//  NetworkTransport.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 09/08/2021.
//

import Foundation

protocol NetworkTransport : AnyObject {
    func load<Decoder: NetworkDecoder>(_ request: URLRequest,
                                       decoder: Decoder,
                                       dispatchQueue: DispatchQueue,
                                       onBackground: Bool,
                                       completion: @escaping (Result<Decoder.resource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier
}

extension NetworkTransport {
    func load<Decoder: NetworkDecoder>(_ request: URLRequest,
                                       decoder: Decoder,
                                       onBackground: Bool = false,
                                       completion: @escaping (Result<Decoder.resource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        /* We cannot declare default argument in protocol decleration */
        load(request, decoder: decoder, dispatchQueue: .global(), onBackground: onBackground, completion: completion)
    }
    
    func load<Decoder: NetworkDecoder>(_ url: URL,
                                       decoder: Decoder,
                                       onBackground: Bool = false,
                                       completion: @escaping (Result<Decoder.resource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        load(URLRequest(url: url), decoder: decoder, onBackground: onBackground, completion: completion)
    }
}
