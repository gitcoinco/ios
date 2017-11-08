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
    
    var bounty = Variable<Bounty?>(nil)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        bindViews()
    }
    
    func bindViews(){
        _ = bounty.asObservable()
            .observeOn(MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [weak self] bounty in
                guard let bounty = bounty else { return }
                
                self?.titleLabel.text = bounty.title
                
                if let avatarUrl = bounty.avatarUrl {
                    
                    Alamofire.request(avatarUrl).responseImage { response in
                        
                        if let image = response.result.value {
                            let circularImage = image.af_imageRoundedIntoCircle()
                            
                            self?.avatarImageView.image = circularImage
                        }
                    }
                }
            })
    }
}
