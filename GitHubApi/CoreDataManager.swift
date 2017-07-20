//
//  CoreDataManager.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 20.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {

    private static var sharedInstance = CoreDataManager()
    
    static var shared: CoreDataManager {
    
        return sharedInstance
    }
    
    private let persistentContainer = NSPersistentContainer(name: "GitHubApi")
    
    private override init() {
        
        super.init()
    }
    
    var viewContext: NSManagedObjectContext {
    
        return self.persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
    
        return self.persistentContainer.newBackgroundContext()
    }
    
    //MARK: - Public
    func initialize(completionHandler: @escaping (Bool) -> Void = {_ in}) {
    
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            
            guard error == nil else {
            
                //FIXME: log error
                completionHandler(false)
                return
            }
            
            completionHandler(true)
        }

    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void){
    
        self.persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
