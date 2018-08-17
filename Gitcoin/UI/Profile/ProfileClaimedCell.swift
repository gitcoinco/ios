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
    @IBOutlet var lblDetails: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        //self.addGradientBackground(firstColor: .lightText, secondColor: .lightGray )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func set(title: String) {
        lblTitle.text = title
    }

    func set(details: Bounty?) {

        var text = ""

        if let bounty =  details {

            var tokenValueString = ""
            var usdtDisplayValueString = ""

            if let tokenValue = bounty.tokenValueString {
                tokenValueString = tokenValue
            }

            if UIScreen.main.bounds.size.height > CGFloat(568.0) && !bounty.usdtDisplayValue.isEmpty {
                usdtDisplayValueString = "(\(bounty.usdtDisplayValue))"
            }

            let expires = bounty.expiresIn

           text =  "\(tokenValueString) \(usdtDisplayValueString) // EXP: \(expires)"
        }

        lblDetails.text = text
    }

    func set(imageUrl: String?) {
        if let imageUrl = imageUrl {
            Alamofire.request(imageUrl).responseImage { response in
                if let image = response.result.value {
                    let circularImage = image.af_imageRoundedIntoCircle()

                    self.avatarImageView.image = circularImage
                }
            }
        }
    }

}
