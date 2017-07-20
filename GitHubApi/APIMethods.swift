//
//  APIMethods.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 20.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import Foundation
import Alamofire

struct APIParameters {
    
    static let baseURL = "https://api.github.com"
}

enum APIMethods {
    
    case LoadUsers
    case LoadFollowers(String)
    
    var requestParameters: (method: Alamofire.HTTPMethod, path: String, parameters: Dictionary<String, AnyObject>?, body: Dictionary<String, AnyObject>?) {
        
        switch self {
        case .LoadUsers:
            
            //let body: [String: AnyObject] = ["offset": offset as AnyObject, "limit": limit as AnyObject]
            
            return (.get, "users", nil, nil)
        case .LoadFollowers(let login):
            //let body: [String: AnyObject] = ["offset": offset as AnyObject, "limit": limit as AnyObject]
            
            return (.get, "users/\(login)/followers", nil, nil)
        }
    }
    
    static func prepareRequest(_ method: APIMethods) -> URLRequest {
        
        let (method, path, parameters, body) = method.requestParameters
        
        var url = URL(string: APIParameters.baseURL)!
        url.appendPathComponent(path)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        do {
            if let parameters = parameters {
                urlRequest = try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            }
            
            if let body = body {
                urlRequest = try Alamofire.JSONEncoding.default.encode(urlRequest, with: body)
            }
        }
        catch let error {
            log.error("Error occured while encoding request: \(error)", LogModule: .HTTP)
        }
        
        
        return urlRequest as URLRequest
    }
}
