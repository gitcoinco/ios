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
    
    var data:[Bounty]?
    
    let disposeBag = DisposeBag()
    
    let bountyCount = Variable(-1)

    @IBOutlet weak var kolodaView: BountyKolodaView!
    
    @IBOutlet weak var profileBarButtonItem: UIBarButtonItem!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BountyCardKolodaAnimator(koloda: kolodaView)
        
        observeUserActions()
        
        //TODO: put on background via observe on
        let bountyCountSubscription = bountyCount
            .asObservable()
            .subscribe(onNext: { count in
                if count >= 0 {
                    TrackingManager.shared.trackEvent(GitcoinEvent.didBountyCountChange(count: count))
                }
            })
        
        disposeBag.insert(bountyCountSubscription)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "bountyDetailsSegue",
            let destination = segue.destination as? BountyDetailsContainerViewController,
            let bounty = sender as? Bounty{
            
                destination.bounty = bounty
        }
    }
}

//MARK: KolodaViewDelegate
extension BountyCardViewController: KolodaViewDelegate {
    
    // Bounty Card has beed tapped fires this event
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
        guard let data = data else { return }
        
        if isEndOfBountiesCard(index) { return }
        
        let bounty = data[index]
        
        TrackingManager.shared.trackEvent(.didTapBounty(bounty: bounty))
        
        
        performSegue(withIdentifier: "bountyDetailsSegue", sender: bounty)
    
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
        
        guard let data = data else { return }
        
        if isEndOfBountiesCard(index) {

            TrackingManager.shared.trackEvent(.didViewEndOfBounties)

            return
        }
        
        let bounty = data[index]
        
        TrackingManager.shared.trackEvent(GitcoinEvent.didViewBounty(bounty: bounty))
    }
    
    /// When an action has been taken on a bounty card, pass the information to the gitcoinAPI
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        guard let data = data else { return }
        
        if isEndOfBountiesCard(index) { return }
        
        // If not connected to network
        if !NetworkReachability.shared.isConnected.value {
            koloda.revertAction()
            
            SCLAlertView(appearance:  gitcoinAppearance()).showWarning("You are not online", subTitle: "Please find a network before continuing.", closeButtonTitle: "DONE")
            
            return
        }
        
        // When usera swipes right for the first time without being signed in
        // pop alert.  Once show alert once via seenSwipeRightBountyAlert
        if  OctokitManager.shared.isSignedOut &&
            direction == SwipeResultDirection.right &&
            !Defaults[UserDefaultKeyConstants.seenSwipeRightBountyAlert]{
            
            let appearance = gitcoinAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            
            alertView.addButton("SIGN IN") {
                
                UIApplication.shared.sendAction(self.profileBarButtonItem.action!, to: self.profileBarButtonItem.target, from: self, for: nil)
                
                koloda.revertAction()
            }
            
            alertView.addButton("CONTINUE BROWSING") {
                Defaults[UserDefaultKeyConstants.seenSwipeRightBountyAlert] = true
            }
            
            alertView.showInfo("Sign In with Github", subTitle: "to get match email intros to this repo owner.")
            
            return
        }
        
        let bounty = data[index]
        let user = OctokitManager.shared.user.value
        
        self.bountyCount.value = self.bountyCount.value - 1
        
        // The api is looking for + or -
        let mappedDirection = direction == SwipeResultDirection.left ? "-" : "+"
        
        TrackingManager.shared.trackEvent(.didSwipeBounty(bounty: bounty, direction: mappedDirection, user: user))

        _ = GitcoinAPIService.shared.provider.rx.request(.fundingSave(bounty: bounty, user: user, direction: mappedDirection))
            .subscribe { event in
                switch event {
                case .success(_):
                    
                    // dont set lastViewedBountyId if not logged in
                    // guard let _ = user else { return }
                    
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
        guard let data = data else { return 0 }
        
        return data.count + 1 // + 1 is the final out of bounties card view
    }
    
    /// instantiate a custom BountyCardView and set its bounty value
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        guard let data = data else { return UIView() }

        if isEndOfBountiesCard(index) {
            guard let bountyCardView = Bundle.main.loadNibNamed("EndOfBountiesCardView", owner: self, options: nil)?[0] as? EndOfBountiesCardView
                else {
                    return UIView()
            }
            
            bountyCardView.refreshBountiesClosure = {
                Defaults.remove(UserDefaultKeyConstants.lastViewedBountyId)
                Defaults.remove(UserDefaultKeyConstants.seenSwipeRightBountyAlert)
                
                self.loadData()
            }
            
            return bountyCardView
        }
        
        return bountyCardView(for: data[index])
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("BountyCardOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    fileprivate func bountyCardView(for bounty:Bounty) -> UIView {
        return BountyCardView.fromNib(with: bounty, and: self.kolodaView)
    }
}

extension BountyCardViewController {
    func loadData(){
        //TODO: setup a UIApplication.keyWindow so we dont have to set the container view for the spinner
        SwiftSpinner.useContainerView(self.view)
        SwiftSpinner.show("Loading...")
        
        // Filter the results so that we only display what we haven't seen
        let lastViewedBountyId = Defaults[UserDefaultKeyConstants.lastViewedBountyId]
        let userKeywords = Defaults[UserDefaultKeyConstants.userKeywords]
        
        //TODO: Add timeout
        _ = GitcoinAPIService.shared.provider.rx.request(.bounties(lastViewedBountyId: lastViewedBountyId, userKeywords: userKeywords))
            .map(to: [Bounty].self)
            .subscribe { [unowned self] event in
                switch event {
                case .success(let repos):
                    self.data = repos
                    
                    self.kolodaView.resetCurrentCardIndex()
                    
                    SwiftSpinner.hide()
                    
                    self.bountyCount.value = self.data?.count ?? 0
                
                case .error(let e):
                    
                    TrackingManager.shared.trackEvent(.didError(title:"Bounties API Request Error", error: e))
                    
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
                    
                    let appearance = gitcoinAppearance(
                        showCloseButton: false
                    )
                    
                    let alertView = SCLAlertView(appearance: appearance)

                    alertView.addButton("TRY AGAIN") {
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
                    Defaults.remove(UserDefaultKeyConstants.seenSwipeRightBountyAlert)
                }
            })
        
        disposeBag.insert(subscription)
    }
    
    /// Helper method to determine if the given index is the last index of
    ///   our bounty data array. This last index represents the "End of Bounties" View
    func isEndOfBountiesCard(_ index: Int) -> Bool {
        return index >= (data?.count ?? 0)
    }
}
