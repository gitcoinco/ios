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
import SCLAlertView
import SwiftyUserDefaults
import SwiftSpinner
import Crashlytics
import Alamofire
import AlamofireImage

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
        
        Answers.logCustomEvent(withName: "End of Bounties")
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
        let bounty = data[index]
    
        Answers.logContentView(withName: "Tap",
                               contentType: "Bounty",
                               contentId: bounty.idString,
                               customAttributes: ["title": bounty.title])
        
        //TODO: What to do on tap??? native detail? someother action?
        if let gitHubUrl = bounty.githubUrl {
            UIApplication.shared.open(URL(string: gitHubUrl)!, options: [:], completionHandler: { _ in
                
            })
        }
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        let bounty = data[index]
        
        Answers.logContentView(withName: "View",
                               contentType: "Bounty",
                               contentId: bounty.idString,
                               customAttributes: ["title": bounty.title])
    }
    
    /// When an action has been taken on a bounty card, pass the information to the gitcoinAPI
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let bounty = data[index]
        let user = OctokitManager.shared.user.value
        
        // The api is looking for + or -
        let mappedDirection = direction == SwipeResultDirection.left ? "-" : "+"
        
        Answers.logContentView(withName: "Swipe",
                               contentType: "Bounty",
                               contentId: bounty.idString,
                               customAttributes: ["title": bounty.title,
                                                  "direction": mappedDirection,
                                                  "user_email": user?.email ?? "",
                                                  "github_username": user?.login ?? ""])

        _ = gitcoinAPI.rx.request(.fundingSave(bounty: bounty, user: user, direction: mappedDirection))
            .subscribe { event in
                switch event {
                case .success(_):
                    // set the lastViewedBountyId after a successful action has been taken
                    Defaults[UserDefaultKeyConstants.lastViewedBountyId] = bounty.id
                    
                    logger.verbose("set lastViewedBountyId=\(Defaults[UserDefaultKeyConstants.lastViewedBountyId] ?? -1)")
                case .error(let error):
                    logger.error(error)
                }
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
    
    /// instantiate a custom BountyCardView and set its bounty value
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        guard let bountyCardView = Bundle.main.loadNibNamed("BountyCardView", owner: self, options: nil)?[0] as? BountyCardView
            else { return UIView() }
        
       let bounty = data[index]
        
        bountyCardView.titleLabel.text = bounty.title
        
        if let avatarUrl = bounty.avatarUrl {
            
            Alamofire.request(avatarUrl).responseImage { response in
                
                if let image = response.result.value {
                    let circularImage = image.af_imageRoundedIntoCircle()
                    
                    bountyCardView.avatarImageView.image = circularImage
                }
            }
        }
        
        return bountyCardView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("BountyCardOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}

extension BountyCardViewController {
    func loadData(){
        //TODO: setup a UIApplication.keyWindow so we dont have to set the container view for the spinner
        SwiftSpinner.useContainerView(self.view)
        SwiftSpinner.show("Loading...")
        
        // Filter the results so that we only display what we haven't seen
        let lastViewedBountyId = Defaults[UserDefaultKeyConstants.lastViewedBountyId]
        
        _ = gitcoinAPI.rx.request(.bounties(lastViewedBountyId: lastViewedBountyId))
            .map(to: [Bounty].self)
            .subscribe { [unowned self] event in
                switch event {
                case .success(let repos):
                    self.data = repos
                    self.kolodaView.reloadData()
                    SwiftSpinner.hide()
                case .error(let e):
                    
                    Answers.logCustomEvent(withName: "Bounties API Request Error", customAttributes: ["error": e])
                    
                    guard let error = e as? MoyaError else {
                        return
                    }
                    
                    switch error {
                    case .imageMapping(let response):
                        logger.error(response)
                    case .jsonMapping(let response):
                        logger.error(response)
                    case .statusCode(let response):
                        logger.error(response)
                    case .stringMapping(let response):
                        logger.error(response)
                    case .objectMapping(let error, let response):
                        // error is DecodingError
                        logger.error(error)
                        logger.error(response)
                    case .encodableMapping(let error):
                        logger.error(error)
                    case .underlying(let error, let response):
                        logger.error(error)
                        logger.error(response.debugDescription)
                    case .requestMapping(let url):
                        logger.error(url)
                    case .parameterEncoding(let error):
                        logger.error(error)
                    }
                    
                    //TODO: How should we display errors?
                    
                    SwiftSpinner.hide()
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    
                    let alertView = SCLAlertView(appearance: appearance)

                    alertView.addButton("Try Again") {
                        self.loadData()
                    }
                    
                    alertView.showError("Something went wrong", subTitle: error.localizedDescription)
                }
        }
    }
}
