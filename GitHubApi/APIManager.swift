//
//  APIManager.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 20.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public enum ServerResponseCode: Int {
    case Success
    case Failure
}

public struct Response {
    
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public var responseCode: ServerResponseCode
    public let afResult: Alamofire.Result<Any>
    public var errorMessage: String?
    
    public var value:Any? {
        return afResult.value
    }
    
    public var requestError:Error? {
        return afResult.error
    }
    
    public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, afResult: Result<Any>, responseCode: ServerResponseCode) {
        self.request = request
        self.response = response
        self.data = data
        self.afResult = afResult
        self.responseCode = responseCode
    }
}

typealias APIManagerDownloadRequestHandler = (Data?, Error?) -> Void

class APIManager {
    
    static let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        
        return SessionManager(configuration: configuration)
    }()
    
    static func performRequest(_ method: APIMethods, completionHandler: @escaping (Response) -> Void) {
        
        let urlRequest = APIMethods.prepareRequest(method)
        let request = self.manager.request(urlRequest)
        
        if urlRequest.httpBody != nil {
            log.verbose("Sending request: \(String(describing: String(data: urlRequest.httpBody!, encoding: String.Encoding.utf8)))", LogModule: LogModule.HTTP)
        }
        
        request.responseJSON { afResponse in
            var response = Response(request: afResponse.request, response: afResponse.response, data: afResponse.data, afResult: afResponse.result, responseCode: ServerResponseCode.Success)
            
            log.verbose("Received result: \(String(describing: response.afResult.value))", LogModule: .HTTP)
            
            switch afResponse.result {
            case .success(let value):
                let json = JSON(value)
                
                if let error = json["error"].string {
                    response.responseCode = .Failure
                    response.errorMessage = error
                }
                else {
                    response.responseCode = .Success
                }
                break
            case .failure(let error):
                response.responseCode = .Failure
                log.error("Some error occured while executing request: \(error)", LogModule: .HTTP)
                break
            }
            
            completionHandler(response)
        }
    }
    
    static func performDownloadRequest(urlString: String, completionHandler: @escaping APIManagerDownloadRequestHandler) {
        
        Alamofire.request(urlString).responseData(completionHandler: {response in
            if let error = response.error {
                log.error("Error occured while performing download request: \(error)", LogModule: .HTTP)
                completionHandler(nil, error)
                return
            }
            
            let data = response.value
            completionHandler(data, nil)
        })
    }
}
