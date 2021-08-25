//
//  NetworkDecoder.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 25/08/2021.
//

import Foundation

protocol NetworkDecoder {
    associatedtype resource: ApiResource
    func decode(_ data: Data) throws -> resource.ModelType?
}

extension NetworkDecoder {
    func decode(_ data: Data) throws -> resource.ModelType? {
        return nil
    }
}

class ApiDecoder<APIResource: ApiResource>: NetworkDecoder {
    typealias resource = APIResource
}
