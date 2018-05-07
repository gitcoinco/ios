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
import RxCocoa

class BountyCardView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var fundingTokenAmountLabel: UILabel!
    
    @IBOutlet weak var fundingUSDAmountLabel: UILabel!
    @IBOutlet weak var keywordContainer: UIView!
    @IBOutlet weak var postedOnLabel: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    @IBOutlet weak var negativeCardActionButton: UIButton!
    
    @IBOutlet weak var positiveCardActionButton: UIButton!
    
    let tagsField = GitCoinWSTagField()
    
    let disposeBag = DisposeBag()
    
    var kolodaView: BountyKolodaView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        observeUI()
    }
    
    class func fromNib(with bounty: Bounty, and _kolodaView: BountyKolodaView) -> BountyCardView {
        if let bountyCardView = Bundle.main.loadNibNamed(String(describing: BountyCardView.self), owner: nil, options: nil)![0] as? BountyCardView{
        
            bountyCardView.kolodaView = _kolodaView
            
            bountyCardView.titleLabel.text = bounty.title
            
            bountyCardView.setupTagField(for: bounty)
            
            if let avatarUrl = bounty.avatarUrl {
                
                Alamofire.request(avatarUrl).responseImage { response in
                    
                    if let image = response.result.value {
                        
                        let circularImage = image.af_imageRoundedIntoCircle()
                        
                        bountyCardView.avatarImageView.image = circularImage
                    }
                }
            }
            
            bountyCardView.descriptionText.text = bounty.descriptionText ?? ""
            
            bountyCardView.fundingTokenAmountLabel.text = bounty.tokenValueString
            
            bountyCardView.fundingUSDAmountLabel.text = bounty.usdtDisplayValue
            
            bountyCardView.postedOnLabel.text = bounty.createdAgo
            
            return bountyCardView
        }
        
        return BountyCardView()
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
    
    /// Subscribe to actions on various ui/buttons
    func observeUI(){
        let negativeCardActionButtonSubscription = negativeCardActionButton.rx.tap.bind {
            self.kolodaView?.swipe(.left)
        }
        
        disposeBag.insert(negativeCardActionButtonSubscription)
        
        let positiveCardActionButtonSubscription = positiveCardActionButton.rx.tap.bind {
            self.kolodaView?.swipe(.right)
        }
        
        disposeBag.insert(positiveCardActionButtonSubscription)
    }
}
