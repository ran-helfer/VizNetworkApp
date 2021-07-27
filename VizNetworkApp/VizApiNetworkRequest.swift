//
//  VizApiNetworkRequest.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

class VizApiNetworkRequest<Resource: VizApiResource> {
    let resource: Resource
    init(resource: Resource) {
        self.resource = resource
    }
}


extension VizApiNetworkRequest: VizBaseNetworkRequest {
    func decode(_ data: Data) -> Resource.ModelType? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let wrapper = try? decoder.decode(Resource.ModelType.self, from: data)
        return wrapper
    }
    
    func execute(withCompletion completion: @escaping (Result<Resource.ModelType, Error>) -> Void) where Resource: VizApiResource {
        
        print(resource)
        print(resource.basePath)
        print(resource.path)
        
        
        load(resource.url, withCompletion: completion)
    }
    
}
