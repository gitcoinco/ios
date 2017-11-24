//
//  BountyCardView.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 10/31/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import AlamofireImage

class BountyCardView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var fundingTokenAmountLabel: UILabel!
    @IBOutlet weak var fundingTokenName: UILabel!
    
    @IBOutlet weak var fundingUSDAmountLabel: UILabel!
    @IBOutlet weak var keywordContainer: UIView!
    @IBOutlet weak var postedOnLabel: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    let tagsField = GitCoinWSTagField()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func fromNib(with bounty: Bounty) -> BountyCardView {
        let bountyCardView = Bundle.main.loadNibNamed(String(describing: BountyCardView.self), owner: nil, options: nil)![0] as! BountyCardView
        
        bountyCardView.titleLabel.text = bounty.title
        
        bountyCardView.setupTagField(for: bounty)
        
        if let avatarUrl = bounty.avatarUrl {
            
            Alamofire.request(avatarUrl).responseImage { response in
                
                if let image = response.result.value {
                    let circularImage = image.af_imageRounded(withCornerRadius: 20.0, divideRadiusByImageScale: true)
                    
                    bountyCardView.avatarImageView.image = circularImage
                }
            }
        }
        
        bountyCardView.fundingTokenName.text = bounty.tokenName ?? ""
        
        bountyCardView.descriptionText.text = bounty.descriptionText ?? ""
        
        if let valueTrue = bounty.valueTrue {
            bountyCardView.fundingTokenAmountLabel.text = String(describing: valueTrue)
        }else{
            bountyCardView.fundingTokenAmountLabel.text = ""
        }
        
        bountyCardView.fundingUSDAmountLabel.text = bounty.usdtDisplayValue
        
        bountyCardView.postedOnLabel.text = bounty.createdAgo
        
        return bountyCardView
    }
    
    fileprivate func setupTagField(for bounty: Bounty) {
        
        guard let keywords = bounty.keywordArray else {
            return
        }
        
        tagsField.readOnly = true
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        keywordContainer.addSubview(tagsField)
        
        NSLayoutConstraint.activate([
            tagsField.topAnchor.constraint(equalTo: keywordContainer.topAnchor),
            tagsField.leadingAnchor.constraint(equalTo: keywordContainer.leadingAnchor),
            tagsField.trailingAnchor.constraint(equalTo: keywordContainer.trailingAnchor),
            tagsField.bottomAnchor.constraint(equalTo: keywordContainer.bottomAnchor),
        ])
        
        tagsField.addTags(keywords)
    }
}
