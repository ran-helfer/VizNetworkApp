//
//  VizApiNetworkRequest.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

class VizApiNetworkRequest<APIResource: VizApiResource> : VizBaseNetworkRequest {
    var apiResource: APIResource
    init(apiResource: APIResource) {
        self.apiResource = apiResource
    }
    
    func decodeData(_ data: Data) -> APIResource.ModelType? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let wrapper = try? decoder.decode(APIResource.ModelType.self, from: data)
        return wrapper
    }
    
    func execute(withCompletion completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> URLSessionDataTask? where APIResource: VizApiResource {
        return load(apiResource.url, withCompletion: completion)
    }
    
    func execute(withCompletion completion: @escaping (Result<APIResource.ModelType, Error>) -> Void) -> URLSessionDataTask? where APIResource: VizHttpApiResource {
        guard let request = apiResource.urlRequest() else {
            print("could not get url request")
            completion(.failure(VizBaseNetworkRequestError.failed))
            return nil
        }
        return load(request, withCompletion: completion)
    }
}
