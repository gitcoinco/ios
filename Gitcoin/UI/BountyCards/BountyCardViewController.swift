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
import Moya
import Moya_ModelMapper
import Alamofire
import AlamofireImage
import SCLAlertView
import Octokit

class BountyCardViewController: UIViewController {
    let frameAnimationSpringBounciness: CGFloat = 9
    let frameAnimationSpringSpeed: CGFloat = 16
    let kolodaCountOfVisibleCards = 2
    let kolodaAlphaValueSemiTransparent: CGFloat = 0.1
    
    var data = [Bounty]()

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
    
    //TODO: how to persist the state of bounties that the user isnt interested in
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(.left)
    }
    
    //TODO: Shall we make an api call to connect this user to the bounty creator?
    // then what will we do with this "liked" bounty? hide it? save it somewhere?
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
    }

    //TODO: reset state of app here? or perhaps just recent state?
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
}

//MARK: KolodaViewDelegate
extension BountyCardViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        //TODO: Need copy and action
        
        // https://github.com/vikmeup/SCLAlertView-Swift
        SCLAlertView().showSuccess("No More Bounties", subTitle: "TBD: Text about how your going to get a push notification when new bounties are available!", closeButtonTitle: "Start Over")
        
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //TODO: What to do on tap??? native detail? someother action?
        if let gitHubUrl = data[index].githubUrl {
            UIApplication.shared.open(URL(string: gitHubUrl)!, options: [:], completionHandler: { _ in
                
            })
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
        
        //TODO: RxBinding data to view elements
        let bountyCardView = Bundle.main.loadNibNamed("BountyCardView", owner: self, options: nil)?[0] as? BountyCardView
        
        bountyCardView?.titleLabel.text = item.title
        
        if let avatarUrl = item.avatarUrl {
            
            Alamofire.request(avatarUrl).responseImage { response in
                
                if let image = response.result.value {
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
        let provider = MoyaProvider<GitcoinAPIService>()
        
        _ = provider.rx.request(.bounties)
            .mapOptional(to: [Bounty].self)
            .subscribe { [unowned self] event in
                switch event {
                case .success(let repos):
                    if let repos = repos {
                        self.data = repos
                        self.kolodaView.reloadData()
                    }
                    
                case .error(let error):
                    //TODO: better error handling
                    print(error)
                }
        }
    }
}
