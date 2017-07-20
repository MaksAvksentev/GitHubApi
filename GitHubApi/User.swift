//
//  User.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 20.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import Foundation
import CoreData
import BNRCoreDataStack
import SwiftyJSON

struct UserJsonKeys {

    static let id = "id"
    static let login = "login"
    static let avatar_url = "avatar_url"
    static let followers_url = "followers_url"
}

extension User {

    class func create(inContext context: NSManagedObjectContext, json: JSON) -> User {
    
        let entity = User(entity: User.entity(), insertInto: context)
        
        entity.id = json[UserJsonKeys.id].stringValue
        entity.login = json[UserJsonKeys.login].stringValue
        entity.avatar_url = json[UserJsonKeys.avatar_url].stringValue
        entity.followers_url = json[UserJsonKeys.followers_url].stringValue
        
        return entity
    }
    
    class func find(inContext context: NSManagedObjectContext, id: String) -> User? {
    
        let predicate = NSPredicate(format: "id = %@", id)
        
        guard let user = try? self.findFirstInContext(context, predicate: predicate) else {
        
            return nil
        }
        
        return user
    }
    
    class func findAll(inContext context: NSManagedObjectContext) -> [User] {
        
        guard let users = try? self.allInContext(context) else {
            
            return [User]()
        }
        
        return users
    }
    
    func update(withJSON json: JSON) {
    
        self.avatar_url = json[UserJsonKeys.avatar_url].stringValue
        self.login = json[UserJsonKeys.login].stringValue
        self.avatar = nil
    }
    
}
