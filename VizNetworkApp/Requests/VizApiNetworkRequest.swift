//
//  VizApiNetworkRequest.swift
//  VizNetworkApp
//
//  Created by Ran Helfer on 27/07/2021.
//

import Foundation

protocol VizBaseNetworkRequest: AnyObject {
    associatedtype ModelType
    func decodeData(_ data: Data) -> ModelType?
    func execute(withCompletion completion: @escaping (Result<ModelType, Error>) -> Void) -> URLSessionDataTask?
}

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
            completion(.failure(VizNetworkRequestError.failed))
            return nil
        }
        return load(request, withCompletion: completion)
    }
}

extension VizApiNetworkRequest {
    func load(_ request: URLRequest,
              withCompletion completion: @escaping (Result<ModelType, Error>) -> Void) -> URLSessionDataTask? {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let weakSelf = self else {return}
            weakSelf.handleRequestResponse(data: data,
                                           response: response,
                                           error: error,
                                           completion: completion)
        }
        return task
    }
    
    func load(_ url: URL, withCompletion completion: @escaping (Result<ModelType, Error>) -> Void) -> URLSessionDataTask? {
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response , error) -> Void in
            guard let weakSelf = self else {return}
            weakSelf.handleRequestResponse(data: data,
                                           response: response,
                                           error: error,
                                           completion: completion)
        }
        return task
    }
    
    private func handleRequestResponse(data:Data?,
                                       response:Any?,
                                       error:Error?,
                                       completion: @escaping (Result<ModelType, Error>) -> Void) {
        guard error == nil else {
            if let err = error {
                completion(.failure(err))
            } else {
                completion(.failure(VizNetworkRequestError.recievedErrorFromServer))
            }
            return
        }
        
        if let r = response as? HTTPURLResponse {
            print(r.statusCode)
            print(r)
        }
        guard let data = data,
              let value =  self.decodeData(data) else {
            DispatchQueue.main.async {
                completion(.failure(VizNetworkRequestError.failed))
            }
            return
        }
        DispatchQueue.main.async { completion(.success(value))}
    }
}

enum VizNetworkRequestError: Error {
    case failed
    case recievedErrorFromServer
}
