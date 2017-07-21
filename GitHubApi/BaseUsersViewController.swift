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

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: UsersDataSource = UsersDataSource(withState: .None)
    var login: String?
    
    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    //MARK: - LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.configureTableView()
        //let loadNew = self.dataSource.isEmpty
    }
    //MARK: - Private
    private func configureTableView() {
    
        self.tableView.register(UserTableViewCell.nib(), forCellReuseIdentifier: UserTableViewCell.reuseIdentifier)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
        
        self.dataSource.delegate = self
        self.dataSource.initialize()
        
        self.configureSelection()
        
        self.refreshUsers()
        self.tableView.reloadData()
    }
    
    private func configureSelection() {
    
        switch dataSource.state {
        case .Users:
            self.tableView.allowsSelection = true
        default:
            self.tableView.allowsSelection = false
        }
    }
    
    private func startIndicator() {
        
        self.indicator.center = self.view.center
        self.indicator.hidesWhenStopped = true
        self.indicator.startAnimating()
        self.view.addSubview(self.indicator)
    }
    
    private func stopIndicator() {
    
        self.indicator.stopAnimating()
      
    }
    
    //MARK: - Main
    func refreshUsers() {
        
        self.startIndicator()
        
        
        self.dataSource.update(withUser: self.login,completionHandler: {[weak self] success, error in
           
            switch success {
            case true:
                DispatchQueue.main.async {
                    self?.stopIndicator()
                    self?.tableView.reloadData()
                }
                break
            case false:
                DispatchQueue.main.async {
                    self?.presentErrorAlert(message: error?.localizedDescription, animated: true)
                }
                break
            }
        })
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard self.dataSource.state != .Followers else {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let user = dataSource.user(forIndexPath: indexPath) else {
        
            return
        }
        
        let viewController = UIStoryboard.loadFollowersFromMain(FollowersViewController.className)
        viewController.login = user.login!
        viewController.navigationItem.title = user.login!
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.dataSource.users.count - 1 {
        
            self.refreshUsers()
        }
    }
    
    //MARK: - UsersDataSourceProtocol
    func typeForDataSource() -> DataSourceState {
        
        return .None
    }
    
}
