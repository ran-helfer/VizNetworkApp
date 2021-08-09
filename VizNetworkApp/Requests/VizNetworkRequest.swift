//
//  VizBaseNetworkRequest.swift
//  VizNetwork
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

protocol VizNetworkRequest: AnyObject {
    associatedtype ModelType: Decodable
}

extension VizNetworkRequest {
    func load(_ request: URLRequest,
              completion: @escaping (Result<ModelType, Error>) -> Void) -> String {
        return VizNetworkManager.shared.load(request, responseModelType: ModelType.self, completion: completion)
    }
    
    func load(_ url: URL, completion: @escaping (Result<ModelType, Error>) -> Void) -> String {
        return VizNetworkManager.shared.load(url, responseModelType: ModelType.self, completion: completion)
    }
}

class VizApiNetworkRequest<APIResource: VizApiResource> : VizNetworkRequest {
    
    typealias ModelType = APIResource.ModelType
    
    let failedToRetrieveUrlFromApiResource = "failedToRetrieveUrlFromApiResource"
    var apiResource: APIResource
    init(apiResource: APIResource) {
        self.apiResource = apiResource
    }
    
    func execute(withCompletion completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> String where APIResource: VizApiResource {
        return load(apiResource.url, completion: completion)
    }
    
    func execute(withCompletion completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> String where APIResource: VizHttpApiResource {
        guard let request = apiResource.urlRequest() else {
            print("could not get url request")
            completion(.failure(VizNetworkError.urlError(URLError(.badURL))))
            return failedToRetrieveUrlFromApiResource
        }
        return load(request, completion: completion)
    }
}

