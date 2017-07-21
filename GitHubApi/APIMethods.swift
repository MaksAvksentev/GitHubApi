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
    
    case LoadUsers(since: Int, per_page: Int)
    case LoadFollowers(login: String, page: Int, per_page: Int)
    
    var requestParameters: (method: Alamofire.HTTPMethod, path: String, parameters: Dictionary<String, AnyObject>?, body: Dictionary<String, AnyObject>?) {
        
        switch self {
        case .LoadUsers(let since, let per_page):
            
            let body: [String: AnyObject] = ["since": since as AnyObject, "per_page": per_page as AnyObject]
            
            return (.get, "users", body, nil)
        case .LoadFollowers(let login, let page, let per_page):
            
            let body: [String: AnyObject] = ["per_page": per_page as AnyObject, "page": page as AnyObject]
             
            return (.get, "users/\(login)/followers", body, nil)
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
