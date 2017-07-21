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

enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

protocol UsersDataSourceProtocol: class {
    
    func typeForDataSource() -> DataSourceState
}

class UsersDataSource: NSObject, UITableViewDataSource {

    var state: DataSourceState = .None
    
    weak var delegate: UsersDataSourceProtocol?
    private var thumbnailDictionary = [String: Data]()
    
    var users: [String] {
    
        return UsersStore.shared.usersIdsArray(forType: state)
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
        
        UsersStore.shared.page = 0
        UsersStore.shared.cleanFollowers()
        
        self.state = type
    }
    
    func update(withUser login: String? = nil, completionHandler: @escaping UsersStoreCompletionHandler) {
        
        switch self.state {
        case .Users:
            UsersStore.shared.updateUsers(completionHandler: completionHandler)
        case .Followers:
            UsersStore.shared.updateFollowers(forUser: login!, completionHandler: completionHandler)
        default:
            break
        }
    }
    
    func user(forIndexPath indexPath: IndexPath) -> User? {
        
        guard let user = User.find(inContext: CoreDataManager.shared.viewContext, id: self.users[indexPath.row]) else {
            return nil
        }
        
        return user
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        guard let user = self.user(forIndexPath: indexPath) else {
        
            return cell
        }
        
        switch state {
        case .Users:
            cell.accessoryType = .disclosureIndicator
        case .Followers:
            cell.accessoryType = .none
        default:
            break
        }
        
        cell.loginLabel.text = user.login
        cell.linkLabel.text = user.html_url
        
        if let imageData = user.avatar, let image = UIImage(data: imageData as Data) {
            
            let compressedData = UIImageJPEGRepresentation(image, JPEGQuality.low.rawValue)!
            let compressedImage = UIImage(data: compressedData)
            
            cell.avatarView.image = compressedImage
        } else {
            
            APIManager.performDownloadRequest(urlString: user.avatar_url!, completionHandler: {[weak cell] data, error in
                guard error == nil, let data = data else {
                    //FIXME: Handle error here
                    return
                }
                
                if let image = UIImage(data: data) {
                    
                    let compressedData = UIImageJPEGRepresentation(image, JPEGQuality.low.rawValue)!
                    let compressedImage = UIImage(data: compressedData)
                    
                    user.avatar = data as NSData?
                    //CoreDataManager.shared.saveContext()
                    
                    DispatchQueue.main.async {
                        cell?.avatarView.image = compressedImage
                    }
                }
            })

        }
        
        return cell
    }
}
