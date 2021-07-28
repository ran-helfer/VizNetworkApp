//
//  VizApiNetworkRequest.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

class VizApiNetworkRequest<RequestStructure: VizApiRequestStructure> {
    let requestStructure: RequestStructure
    init(requestStructure: RequestStructure) {
        self.requestStructure = requestStructure
    }
}

extension VizApiNetworkRequest: VizBaseNetworkRequest {
    
    func decodeData(_ data: Data) -> RequestStructure.ModelType? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let wrapper = try? decoder.decode(RequestStructure.ModelType.self, from: data)
        return wrapper
    }
    
    func execute(withCompletion completion: @escaping (Result<RequestStructure.ModelType, Error>) -> Void) where RequestStructure: VizApiRequestStructure {
        load(requestStructure.url, withCompletion: completion)
    }
    
}
