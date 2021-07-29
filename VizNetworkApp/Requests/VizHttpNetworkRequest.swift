//
//  VizHttpNetworkRequest.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 29/07/2021.
//

import Foundation

class VizHttpNetworkRequest<RequestStructure: VizHttpRequestStructure> : VizApiNetworkRequest<RequestStructure> {
    override func execute(withCompletion completion: @escaping (Result<RequestStructure.ModelType, Error>) -> Void) -> URLSessionDataTask? where RequestStructure: VizHttpRequestStructure {
        guard let urlRequest = requestStructure.urlRequest else {
            assertionFailure("could not get urlRequest")
            return nil
        }
        return load(urlRequest, withCompletion: completion)
    }
}
