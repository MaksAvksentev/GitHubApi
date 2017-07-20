//
//  StoryboardUtilities.swift
//  GitHubApi
//
//  Created by Maksim Avksentev on 21.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum Storyboard : String {
    
    case main = "Main"
}

fileprivate extension UIStoryboard {
    
    static func loadFromMain(_ identifier: String) -> UIViewController {
        return load(from: .main, identifier: identifier)
    }
    
    static func load(from storyboard: Storyboard, identifier: String) -> UIViewController {
        let uiStoryboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        return uiStoryboard.instantiateViewController(withIdentifier: identifier)
    }
}

extension UIStoryboard {
    
    class func loadFollowersFromMain(_ identifier: String) -> FollowersViewController {
        
        return loadFromMain(FollowersViewController.className) as! FollowersViewController
    }

}
