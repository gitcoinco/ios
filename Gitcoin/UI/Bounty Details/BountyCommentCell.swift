//
//  BountyCommentCell.swift
//  Gitcoin
//
//  Created by John Brunelle on 4/13/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit

class BountyCommentCell: UITableViewCell {
    
    @IBOutlet var lblComment: UILabel!
    @IBOutlet var lblUser: UILabel!
    @IBOutlet weak var backingView: UIView!
    
    func set(comment: String) {
        lblComment.text = comment
    }
    
    func set(user: String, createdOn: Date?) {
        
        var created = "a while ago"
        
        if let createdOn = createdOn {
            created = createdOn.toStringWithRelativeTime().capitalized
        }
        
        lblUser.text = "\(user) commented \(created)"
    }
    
    func set(isCommentOwner: Bool = false){
        
        if isCommentOwner == true{
            backingView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 0.0, alpha: 0.28)
            backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 0.0, alpha: 0.28)
            return
        }
        
        backingView.backgroundColor = UIColor(red: 204/255, green: 221/255, blue: 201/255, alpha: 1)
        backgroundColor = UIColor(red: 235/255, green: 242/255, blue: 234/255, alpha: 1)
        
    }
    
}
