//
//  NetworkRequest.swift
//  NetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

protocol NetworkRequest: AnyObject {
    associatedtype ModelType: Decodable
}

extension NetworkRequest {
    func load(_ request: URLRequest,
              completion: @escaping (Result<ModelType, Error>) -> Void) -> String {
        return NetworkManager.shared.load(request, responseModelType: ModelType.self, completion: completion)
    }
    
    func load(_ url: URL, completion: @escaping (Result<ModelType, Error>) -> Void) -> String {
        return NetworkManager.shared.load(url, responseModelType: ModelType.self, completion: completion)
    }
}

class ApiNetworkRequest<APIResource: ApiResource> : NetworkRequest {
    
    typealias ModelType = APIResource.ModelType
    
    let failedToRetrieveUrlFromApiResource = "failedToRetrieveUrlFromApiResource"
    var apiResource: APIResource
    init(apiResource: APIResource) {
        self.apiResource = apiResource
    }
    
    func execute(withCompletion completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> String where APIResource: ApiResource {
        return load(apiResource.url, completion: completion)
    }
    
    func execute(withCompletion completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> String where APIResource: HttpApiResource {
        guard let request = apiResource.urlRequest() else {
            print("could not get url request")
            completion(.failure(NetworkError.badURL))
            return failedToRetrieveUrlFromApiResource
        }
        return load(request, completion: completion)
    }
}

