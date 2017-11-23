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
import WSTagsField
import TTTAttributedLabel

class BountyCardView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var fundingTokenAmountLabel: UILabel!
    @IBOutlet weak var fundingTokenName: UILabel!
    
    @IBOutlet weak var fundingUSDAmountLabel: UILabel!
    @IBOutlet weak var keywordContainer: UIView!
    @IBOutlet weak var postedOnLabel: UILabel!
    @IBOutlet weak var descriptionText: TTTAttributedLabel!
    
    let tagsField = WSTagsField()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionText.lineBreakMode = .byTruncatingTail
        descriptionText.verticalAlignment = .top
        
        descriptionText.lineHeightMultiple = 0.0
        descriptionText.firstLineIndent = 0.0
    }
    
    class func fromNib(with bounty: Bounty) -> BountyCardView {
        let bountyCardView = Bundle.main.loadNibNamed(String(describing: BountyCardView.self), owner: nil, options: nil)![0] as! BountyCardView
        
        bountyCardView.titleLabel.text = bounty.title
        
        if let avatarUrl = bounty.avatarUrl {
            
            Alamofire.request(avatarUrl).responseImage { response in
                
                if let image = response.result.value {
                    let circularImage = image.af_imageRounded(withCornerRadius: 15.0, divideRadiusByImageScale: true)
                    
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
        
        bountyCardView.setupTagField(with: bounty.keywords?.components(separatedBy: ","))
        
        return bountyCardView
    }
    
    fileprivate func setupTagField(with keywords: [String]?) {
        
        guard let keywords = keywords else {
            return
        }

        tagsField.backgroundColor = .black
        tagsField.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tagsField.spaceBetweenTags = 10.0
        tagsField.font = .systemFont(ofSize: 12.0)
        tagsField.tintColor = .green
        tagsField.textColor = .black
        tagsField.fieldTextColor = .blue
        tagsField.selectedColor = .black
        tagsField.selectedTextColor = .red

        tagsField.readOnly = true
        
        tagsField.backgroundColor = .white
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
