//
//  NetworkHttpDecoder.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 25/08/2021.
//

import Foundation

protocol HTTPDecode: NetworkDecoder where resource: HttpApiResource {}

extension HTTPDecode {
    func decode(_ data: Data) throws -> resource.ModelType? {
        return try JSONDecoder().decode(resource.ModelType.self, from: data)
    }
}

struct HTTPDecoder<APIResource: HttpApiResource>: HTTPDecode {
    typealias resource = APIResource
}
