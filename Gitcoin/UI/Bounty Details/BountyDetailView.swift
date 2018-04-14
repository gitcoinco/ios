//
//  BountyDetailView.swift
//  Gitcoin
//
//  Created by John Brunelle on 3/4/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class BountyDetailView: UIView {

    let nibName = "BountyDetailView"
    var contentView: UIView?
//
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var keywordContainer: UIView!
    @IBOutlet weak var postedOnLabel: UILabel!
    @IBOutlet weak var funderInfo: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    let tagsField = GitCoinWSTagField()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    
    func populate(with bounty: Bounty?){
        
        guard let bounty = bounty else { return }
        
        print("!!+++ bounty = \(bounty)")
        
        set(imageUrl: bounty.avatarUrl)
        set(title: bounty.title)
        set(keywords: bounty.keywordArray)
        set(funderInfo: bounty.organizationName)
        set(descriptionText: bounty.descriptionText)
        
        let postedText = "\(bounty.createdAgo) - EXP. \(bounty.expiresIn)"
        
         set(posted: postedText)
        
    }
    
    func set(status: String?){
        if let status = status{
            self.statusLabel.text = status
        }
    }
    
    func set(title: String?){
        if let title = title{
            self.titleLabel.text = title
        }
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
    
    func set(keywords: [String]?){
        
        guard let keywords = keywords else {
            return
        }
        
        print(keywords)
        
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
    
    func set(posted: String?){
        if let posted = posted{
            self.postedOnLabel.text = posted
        }
    }
    
    func set(funderInfo: String?){
        if let funderInfo = funderInfo{
            self.funderInfo.text = funderInfo
        }
    }
    
    func set(descriptionText: String?){
        if let descriptionText = descriptionText{
            self.descriptionText.text = descriptionText
        }
    }
}
