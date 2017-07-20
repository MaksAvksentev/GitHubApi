//
//  UserTableViewCell.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 20.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    
    class var reuseIdentifier: String {
        return "UserTableViewCell"
    }
    
    class func nib() -> UINib {
        
        return UINib(nibName: "UserTableViewCell", bundle: Bundle.main)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        self.avatarView.image = nil
    }
}
