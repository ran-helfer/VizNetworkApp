//
//  ApiNetworkRequest.swift
//  NetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

class ApiNetworkRequest<APIResource: ApiResource> {
    
    typealias ModelType = APIResource.ModelType
    
    let failedToRetrieveUrlFromApiResource = "failedToRetrieveUrlFromApiResource"
    var apiResource: APIResource
    private var transport: NetworkTransport?
    
    init(apiResource: APIResource, transport: NetworkTransport = NetworkTransporter.shared) {
        self.apiResource = apiResource
        self.transport = transport
    }
    
    func execute(onBackground: Bool = false, completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier where APIResource: ApiResource {
        return load(apiResource.url, completion: completion)
    }
    
    func execute(onBackground: Bool = false, completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier where APIResource: HttpApiResource {
        guard let request = apiResource.urlRequest() else {
            print("could not get url request")
            completion(.failure(NetworkError.badURL))
            return failedToRetrieveUrlFromApiResource
        }
        return load(request, completion: completion)
    }
}

extension ApiNetworkRequest: NetworkRequest {
    func load(_ request: URLRequest,
              onBackground: Bool = false,
              completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        guard let transport = transport else {
            completion(.failure(NetworkError.transportMissingOnLoad))
            return NetworkError.transportMissingOnLoad.errorDescription()
        }
        return transport.load(request,
                              responseModelType: ModelType.self,
                              completion: completion)
    }
}
