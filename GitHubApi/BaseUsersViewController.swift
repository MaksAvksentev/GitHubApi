//
//  BaseUsersViewController.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 20.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit
import SwiftyJSON

class BaseUsersViewController: BaseViewController, UsersDataSourceProtocol, UITableViewDelegate {

    var dataSource: UsersDataSource = UsersDataSource(withState: .None)
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        APIManager.performRequest(.LoadUsers) { (response) in
            switch response.responseCode {
            case .Success:
                if let value = response.value {
                    
                    let json = JSON(value)
                    let users = json.arrayValue
                    for user in users {
                    
                        let id = user[UserJsonKeys.id].stringValue
                        print(id)
                    }
                    
                }
                
            default:
                break
            }
        }
    }

    //MARK: - UITableViewDelegate
    
    //MARK: - UsersDataSourceProtocol
    func typeForDataSource() -> DataSourceState {
        
        return .None
    }
    
}
