//
//  BountyCardViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 10/31/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import Koloda
import pop
import Alamofire
import AlamofireImage

class BountyCardViewController: UIViewController {
    let frameAnimationSpringBounciness: CGFloat = 9
    let frameAnimationSpringSpeed: CGFloat = 16
    let kolodaCountOfVisibleCards = 2
    let kolodaAlphaValueSemiTransparent: CGFloat = 0.1
    
    var data = [[String:Any]]()

    @IBOutlet weak var kolodaView: BountyKolodaView!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BountyCardKolodaAnimator(koloda: kolodaView)
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        loadData()
    }
    
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
}

//MARK: KolodaViewDelegate
extension BountyCardViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        if let gitHubUrl = data[index]["github_url"] as? String {
            UIApplication.shared.openURL(URL(string: gitHubUrl)!)
        }
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}

// MARK: KolodaViewDataSource
extension BountyCardViewController: KolodaViewDataSource {
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return data.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let item = data[index]
        
        let bountyCardView = Bundle.main.loadNibNamed("BountyCardView", owner: self, options: nil)?[0] as? BountyCardView
        
        bountyCardView?.titleLabel.text = item["title"] as? String
        
       
        if let avatarUrl = item["avatar_url"] as? String {
             print("avatarUrl = \(avatarUrl)")
            
            Alamofire.request(avatarUrl).responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    let circularImage = image.af_imageRoundedIntoCircle()
                    
                    bountyCardView?.avatarImageView.image = circularImage
                }
            }
        }
        
        return bountyCardView!
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("BountyCardOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}

extension BountyCardViewController {
    func loadData(){
        
        Alamofire.request("https://gitcoin.co/api/v0.1/bounties/")
            .responseJSON { response in
                if let bounties = response.result.value as? [[String:Any]]{
                    
                    self.data = bounties
                    
                    self.kolodaView.reloadData()
                    
                    
//                    if let error = bounties["error"] {
//                        print("No venue found | error :\(error)")
//
//                        return
//                    }
//                    let venueCount = bounties.count
//                    print(" count : \(bounties.count)")
//                    if (venueCount == 0) {
//                        print("No venue found")
//                        self.restaurantName.text = "Nothing found! Try again"
//                        self.stopSpinner(nil)
//                        return
//                    }
//                    let venueLimit = min(venueCount, 50)
//                    let randomRestaurantIndex = Int(arc4random_uniform(UInt32(venueLimit)))
//                    print(randomRestaurantIndex)
//                    guard let results = bounties as? NSArray
//                        else {
//                            print ("cannot find key location in \(bounties)")
//                            return
//                    }
//                    for r in results{
//                        let photoURL = NSURL(string:r["photo_url"] as! String)
//                        if let imageData = NSData(contentsOfURL: photoURL!) {
//                            let image  = UIImage(data: imageData)
//
//                            let name = r["name"] as! String
//                            let address = r["address"] as! String
//                            let lat = r["latitude"] as! String
//                            let lng = r["longitude"] as! String
//                            let venue_id = r["venue_id"] as! String
//                            let checkins = r["checkins"] as! UInt
//                            let restaurant = Restaurant(name: name, photo: image, address: address, checkins: checkins, latitude: lat, longitude: lng, venue_id: venue_id)!
//                            self.bounties.append(restaurant)
//
//                            print("\(name) \(checkins) \(lat) \(venue_id)")
//                        }
//
//                    }
//                    let randomRestaurant = self.bounties[randomRestaurantIndex]
//                    self.setRandomRestaurant(randomRestaurant)
//
//                    self.savebounties()
//                    self.stopSpinner(nil)
                }
        }
    }
}
