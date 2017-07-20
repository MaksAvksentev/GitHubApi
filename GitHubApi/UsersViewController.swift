//
//  UsersViewController.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 20.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit

class UsersViewController: BaseUsersViewController {

    //MARK: - UsersDataSourceProtocol
    override func typeForDataSource() -> DataSourceState {
        
        return .Users
    }
}
