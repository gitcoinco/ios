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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
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
    
}
