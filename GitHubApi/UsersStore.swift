//
//  UsersStore.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 20.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias UsersStoreCompletionHandler = (Bool, Error?) -> Void

class UsersStore: NSObject {

    private static var sharedInstance = UsersStore()
    static var shared: UsersStore {
    
        return sharedInstance
    }
    
    private var users = [String]()
    private var followers = [String]()

    private override init() {
    
        super.init()
        
        self.initialize()
    }
    
    //MARK: - Public
    func usersIdsArray(forType type: DataSourceState)  -> [String] {
    
        switch type {
        case .Users:
            
            return self.users
        case .Followers:
            
            return self.followers
        default:
            
            return [String]()
        }
    }
    
    func updateUsers(completionHandler: @escaping UsersStoreCompletionHandler) {
        
        self.update(forType: .Users, completionHandler: completionHandler)
    }
    
    func updateFollowers(forUser login: String,completionHandler: @escaping UsersStoreCompletionHandler) {
        
        self.update(forType: .Followers, completionHandler: completionHandler)
    }
    
    //MARK: - Private
    private func update(forType type: DataSourceState,withUser login: String? = nil, completionHandler: @escaping UsersStoreCompletionHandler) {
        
        guard let method = {() -> APIMethods? in
        
            switch type {
            case .Users:
                return APIMethods.LoadUsers
            case .Followers:
                return APIMethods.LoadFollowers(login!)
            case .None:
                return nil
            }
        }() else {
            return
        }
        
        APIManager.performRequest(method, completionHandler: {response in
            switch response.responseCode {
            case .Success:
                if let value = response.value {
                    let json = JSON(value)
                    let users = json.arrayValue
                    
                    for user in users {
                        let id = user[UserJsonKeys.id].stringValue
                        
                        self.addUserToArray(forType: type, id: id)
                    }
                    
                    self.save()
                    self.mapUsers(fromArray: users, completionHandler: completionHandler)
                }
                break
            case .Failure:
                let error = response.requestError
                completionHandler(false, error)
                break
            }
        })
        
        switch type {
        case .Users:
            break
        case .Followers:
            break
        default:
            break
        }
    }
    
    private func addUserToArray(forType type: DataSourceState, id: String) {
        
        switch type {
        case .Users:
            if !self.users.contains(id) {
                
                self.users.append(id)
            }
        case .Followers:
            if !self.followers.contains(id) {
                
                self.users.append(id)
            }
        default:
            break
        }
    }
    
    private func mapUsers(fromArray array: [JSON], completionHandler: (UsersStoreCompletionHandler)? = nil) {
    
        CoreDataManager.shared.performBackgroundTask { (context) in
            
            for item in array {
            
                if let user = User.find(inContext: context, id: item[UserJsonKeys.id].stringValue) {
                    
                    user.update(withJSON: item)
                } else {
                
                    let _ = User.create(inContext: context, json: item)
                }
            }
            
            context.saveContext({result in
                switch result {
                case .success:
                    completionHandler?(true, nil)
                case .failure(let error):
                    completionHandler?(false, error)
                }
            })
        }
    }

    //MARK: - Storing
    func initialize() {
    
        let usersData = UserDefaults.standard.data(forKey: "Users")
        
        if let data = usersData, let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] {
            
            self.users = array
        }
    }
    
    func save() {
    
        let users = NSKeyedArchiver.archivedData(withRootObject: self.users)
        
        UserDefaults.standard.set(users, forKey: "Users")
        UserDefaults.standard.synchronize()
    }
}
