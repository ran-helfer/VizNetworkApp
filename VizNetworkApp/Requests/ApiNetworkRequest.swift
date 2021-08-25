//
//  ApiNetworkRequest.swift
//  NetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

class ApiNetworkRequest<APIResource: ApiResource> : NetworkRequest {
    
    typealias resource = APIResource
    
    let failedToRetrieveUrlFromApiResource = "failedToRetrieveUrlFromApiResource"
    var apiResource: APIResource
    private weak var transport: NetworkTransport?
    
    init(apiResource: APIResource,
         transport: NetworkTransport = NetworkTransporter.shared) {
        self.apiResource = apiResource
        self.transport = transport
    }
    
    func execute(completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier where APIResource: HttpApiResource {
        guard let transport = transport,
              let urlRequest = apiResource.urlRequest() else {
                completion(.failure(NetworkError.transportMissingOnLoad))
            return NetworkError.transportMissingOnLoad.errorDescription()
        }
        let decoder = HTTPDecoder<APIResource>()
        return transport.load(urlRequest,
                              decoder:decoder,
                              completion: completion)
    }
    
    func execute(completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        guard let transport = transport else {
                completion(.failure(NetworkError.transportMissingOnLoad))
            return NetworkError.transportMissingOnLoad.errorDescription()
        }
        let decoder = ApiDecoder<APIResource>()
        return transport.load(URLRequest(url: apiResource.url),
                              decoder: decoder,
                              completion: completion)
    }
}

