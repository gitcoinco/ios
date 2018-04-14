//
//  StaticViewController.swift
//  StaticTableview
//
//  Created by Craig Clayton on 3/26/18.
//  Copyright © 2018 Spartan Race. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class BountyDetailViewController: UITableViewController {
    
    @IBOutlet weak var lblPosted: UILabel!
    @IBOutlet weak var lblFunderInfo: UILabel!
    @IBOutlet weak var lblIssueDesc: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var keywordContainer: UIView!
    
    var bounty: Bounty?
    let tagsField = GitCoinWSTagField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bounty = bounty{
            setPosted(bounty)
            setFunderInfo(bounty)
            setIssueDesc(bounty)
            set(imageUrl: bounty.avatarUrl)
            set(title: bounty.title)
            set(keywords: bounty.keywordArray)
        }
        
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func setPosted(_ bounty: Bounty){
        lblPosted.text = "\(bounty.createdAgo) - EXP. \(bounty.expiresIn)"
    }
    
    func setFunderInfo(_ bounty: Bounty){
        lblFunderInfo.text = bounty.ownerGithubUsername
    }
    
    func setIssueDesc(_ bounty: Bounty){
        lblIssueDesc.text = bounty.descriptionText
    }
    
    func set(status: String?){
        if let status = status{
            self.lblStatus.text = status
        }
    }
    
    func set(title: String?){
        if let title = title{
            self.lblTitle.text = title
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
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        }
        else {
           return UITableViewAutomaticDimension
        }
        
    }
    
}
