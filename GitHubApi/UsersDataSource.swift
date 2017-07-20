//
//  UsersDataSource.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 20.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit

enum DataSourceState {

    case Users
    case Followers
    case None
}

protocol UsersDataSourceProtocol: class {
    
    func typeForDataSource() -> DataSourceState
}

class UsersDataSource: NSObject, UITableViewDataSource {

    var state: DataSourceState = .None
    
    weak var delegate: UsersDataSourceProtocol?
    
    var users: [String] {
    
        return [String]()
    }
    
    init(withState state: DataSourceState) {
        
        super.init()
        self.state = state
    }
    
    //MARK: - Public
    func initialize() {
    
        guard let type = self.delegate?.typeForDataSource() else {
            
            return
        }
        
        self.state = type
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        return UITableViewCell()
    }
}
