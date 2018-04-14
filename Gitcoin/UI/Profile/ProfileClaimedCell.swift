//
//  ProfileClaimedCell.swift
//  Gitcoin
//
//  Created by John Brunelle on 4/12/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit

class ProfileClaimedCell: UITableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblShortDesc: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(title: String) {
        lblTitle.text = title
    }
    
    func set(desc: String) {
        lblShortDesc.text = desc
    }
    
}
