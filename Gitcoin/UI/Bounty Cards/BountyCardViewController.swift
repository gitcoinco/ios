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
import RxSwift
import RxCocoa

class BountyCardViewController: UIViewController {
    let endOfBountiesSegueIdentifier = "endOfBounties"
    
    let frameAnimationSpringBounciness: CGFloat = 9
    let frameAnimationSpringSpeed: CGFloat = 16
    let kolodaCountOfVisibleCards = 2
    let kolodaAlphaValueSemiTransparent: CGFloat = 0.1
    
    var data = [Bounty]()
    
    let disposeBag = DisposeBag()

    @IBOutlet weak var kolodaView: BountyKolodaView!
    
    @IBOutlet weak var negativeCardActionButton: UIButton!
    @IBOutlet weak var positiveCardActionButton: UIButton!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BountyCardKolodaAnimator(koloda: kolodaView)
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        observeUI()
        
        observeUserActions()
        
        loadData()
    }
}

//MARK: KolodaViewDelegate
extension BountyCardViewController: KolodaViewDelegate {
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
        if isEndOfBountiesCard(index) { return }
        
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
    
    // Don't allow to drag the last "end of bounties" view
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int ) -> Bool {
        
        if isEndOfBountiesCard(index) { return  false }
        
        return true
    }
    
    // Don't allow any actions on the end of bounties view
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        
        if isEndOfBountiesCard(index) { return  [] }
        
        return [.left, .right]
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        
        if isEndOfBountiesCard(index) {
            
            negativeCardActionButton.isHidden = true
            positiveCardActionButton.isHidden = true
            
            Answers.logContentView(withName: "View",
                                   contentType: "End of Bounties",
                                   contentId: "")
            
            return
        }
        
        negativeCardActionButton.isHidden = false
        positiveCardActionButton.isHidden = false
        
        let bounty = data[index]
        
        Answers.logContentView(withName: "View",
                               contentType: "Bounty",
                               contentId: bounty.idString,
                               customAttributes: ["title": bounty.title])
    }
    
    /// When an action has been taken on a bounty card, pass the information to the gitcoinAPI
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        if isEndOfBountiesCard(index) { return }
        
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

        _ = GitcoinAPIService.shared.provider.rx.request(.fundingSave(bounty: bounty, user: user, direction: mappedDirection))
            .subscribe { event in
                switch event {
                case .success(_):
                    // set the lastViewedBountyId after a successful action has been taken
                    // this will ensure the user only sees the bounties once
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
        return data.count + 1 // + 1 is the final out of bounties card view
    }
    
    /// instantiate a custom BountyCardView and set its bounty value
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {

        if isEndOfBountiesCard(index) {
            guard let bountyCardView = Bundle.main.loadNibNamed("EndOfBountiesCardView", owner: self, options: nil)?[0] as? EndOfBountiesCardView
                else {
                    return UIView()
            }
            
            return bountyCardView
        }
        
        return bountyCardView(for: data[index])
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("BountyCardOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    // TODO: move this to BountyCardView view class
    fileprivate func bountyCardView(for bounty:Bounty) -> UIView {
    
        guard let bountyCardView = Bundle.main.loadNibNamed("BountyCardView", owner: self, options: nil)?[0] as? BountyCardView
        else {
            return UIView()
        }
    
        bountyCardView.titleLabel.text = bounty.title
    
        if let avatarUrl = bounty.avatarUrl {
    
        Alamofire.request(avatarUrl).responseImage { response in
    
                if let image = response.result.value {
                    let circularImage = image.af_imageRoundedIntoCircle()
    
                    bountyCardView.avatarImageView.image = circularImage
                }
            }
        }
    
        bountyCardView.typeLabel.text = bounty.bountyType
    
        bountyCardView.projectLengthLabel.text = bounty.projectLength
    
        bountyCardView.expiresOnLabel.text = bounty.expiresIn
    
        bountyCardView.experienceLabel.text = bounty.experienceLevel
    
        bountyCardView.fundedByButton.setTitle(bounty.ownerGithubUsername, for: .normal)
    
        _ = bountyCardView.fundedByButton.rx.tap.bind {
            UIApplication.shared.open(bounty.ownerGithubUrl, options: [:], completionHandler: { _ in
    
            })
        }
    
        bountyCardView.fundingTokenAmountLabel.text = bounty.tokenDisplayValue
    
        bountyCardView.fundingUSDAmountLabel.text = bounty.usdtDisplayValue
    
        bountyCardView.postedOnLabel.text = bounty.createdAgo
    
        return bountyCardView
    }
}

extension BountyCardViewController {
    func loadData(){
        //TODO: setup a UIApplication.keyWindow so we dont have to set the container view for the spinner
        SwiftSpinner.useContainerView(self.view)
        SwiftSpinner.show("Loading...")
        
        // Filter the results so that we only display what we haven't seen
        let lastViewedBountyId = Defaults[UserDefaultKeyConstants.lastViewedBountyId]
        
        //TODO: Add timeout
        _ = GitcoinAPIService.shared.provider.rx.request(.bounties(lastViewedBountyId: lastViewedBountyId))
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
    
    /// Subscribe to user actions
    func observeUserActions(){
        
        let subscription = OctokitManager.shared
            .userActionSubject
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { userAction in
                
                // Reset the last view bounty when logging out
                switch userAction {
                case .signedIn:
                    logger.verbose("User signed in")
                case .signedOut:
                    logger.verbose("User signed out")
                    Defaults.remove(UserDefaultKeyConstants.lastViewedBountyId)
                }
            })
        
        disposeBag.insert(subscription)
    }
    
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
    
    /// Helper method to determine if the given index is the last index of
    ///   our bounty data array. This last index represents the "End of Bounties" View
    func isEndOfBountiesCard(_ index: Int) -> Bool {
        return index >= data.count
    }
}
