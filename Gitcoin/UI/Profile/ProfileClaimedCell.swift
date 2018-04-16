//
//  ProfileClaimedCell.swift
//  Gitcoin
//
//  Created by John Brunelle on 4/12/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ProfileClaimedCell: UITableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

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
    
    func set(imageUrl: String?){
        if let imageUrl = imageUrl{
            Alamofire.request(imageUrl).responseImage { response in
                if let image = response.result.value {
                    let circularImage = image.af_imageRoundedIntoCircle()
                    
                    self.avatarImageView.image = circularImage
                }
            }
        }
    }
    
}
