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

    func execute(completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        assertionFailure("no implementation for execute")
        return ""
    }
    
    func execute(completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier where APIResource: HttpApiResource {
        guard let transport = transport,
              let urlRequest = apiResource.urlRequest() else {
                completion(.failure(NetworkError.transportMissingOnLoad))
            return NetworkError.transportMissingOnLoad.errorDescription()
        }
        return transport.load(urlRequest,
                              responseModelType: APIResource.ModelType.self,
                              completion: completion)
    }
    
    func decode(_ data: Data) throws -> APIResource.ModelType? {
        assertionFailure("no implementation for decode")
        return nil
    }
    
    func decode(_ data: Data) throws -> APIResource.ModelType? where APIResource: HttpApiResource  {
        return try JSONDecoder().decode(APIResource.ModelType.self, from: data)
    }
}

