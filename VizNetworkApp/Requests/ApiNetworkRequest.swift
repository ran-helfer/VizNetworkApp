//
//  ApiNetworkRequest.swift
//  NetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

class ApiNetworkRequest<APIResource: ApiResource> : NetworkRequest {
    
    typealias ModelType = APIResource.ModelType
    
    let failedToRetrieveUrlFromApiResource = "failedToRetrieveUrlFromApiResource"
    var apiResource: APIResource
    private let transport: NetworkTransport
    
    init(apiResource: APIResource, transport: NetworkTransport = NetworkTransporter.shared) {
        self.apiResource = apiResource
        self.transport = transport
    }
    
    func execute(withCompletion completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier where APIResource: ApiResource {
        return load(apiResource.url, completion: completion)
    }
    
    func execute(withCompletion completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> DataTaskStringIdentifier where APIResource: HttpApiResource {
        guard let request = apiResource.urlRequest() else {
            print("could not get url request")
            completion(.failure(NetworkError.badURL))
            return failedToRetrieveUrlFromApiResource
        }
        return load(request, completion: completion)
    }
    
    func load(_ request: URLRequest,
              completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        return transport.load(request, responseModelType: ModelType.self, completion: completion)
    }
    
    func load(_ url: URL, completion: @escaping (Result<ModelType, Error>) -> Void) -> DataTaskStringIdentifier {
        return transport.load(url, responseModelType: ModelType.self, completion: completion)
    }
}

