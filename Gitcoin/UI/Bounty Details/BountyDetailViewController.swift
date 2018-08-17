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
import SCLAlertView
import InputBarAccessoryView
import SwiftyUserDefaults
import RxSwift
import RxCocoa

class BountyDetailViewController: UITableViewController {

    @IBOutlet weak var lblPosted: UILabel!
    @IBOutlet weak var lblFunderInfo: UILabel!
    @IBOutlet weak var lblIssueDesc: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var keywordContainer: UIView!
    @IBOutlet weak var lblClaim: UILabel!
    @IBOutlet weak var btnClaim: UIButton!
    @IBOutlet weak var lblSavedStartWork: UILabel!
    @IBOutlet weak var btnSavedClaim: UIButton!
    @IBOutlet weak var lblUnsave: UILabel!
    @IBOutlet weak var btnUnsave: UIButton!
    let disposeBag = DisposeBag()

    var bounty: Bounty?
    let tagsField = GitCoinWSTagField()
    var kolodaView: BountyKolodaView?
    var isBountyClaimed = false

    @IBOutlet weak var headerContentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("bounty id = \(bounty?.id) sbi = \(bounty?.standardBountiesId)")

        if let bounty = bounty {
            setPosted(bounty)
            setFunderInfo(bounty)
            setIssueDesc(bounty)
            set(imageUrl: bounty.avatarUrl)
            set(title: bounty.title)
            set(keywords: bounty.keywordArray)
            set(status: bounty.status)
        }

        tableView.estimatedRowHeight = 500.0
        tableView.rowHeight = UITableViewAutomaticDimension

        if let bounty = self.bounty, isBountyClaimed == true {
            self.lblClaim.text = "REMOVE"
            self.lblClaim.borderColor = .red
            self.lblClaim.textColor = .red
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let bounty = bounty {
            TrackingManager.shared.trackEvent(GitcoinEvent.didViewBountyDetails(bounty: bounty))
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        // needed to clear the text in the back navigation:

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webviewSegue",
            let destination = segue.destination as? WebViewController {

            destination.title = "SIGN IN"

            destination.currentURL = OctokitManager.shared.oAuthConfig.authenticate()
        }
    }

    @IBAction func doUnSaveTap(_ sender: Any) {

        lblUnsave.text = "UNSAVED"
        btnUnsave.isUserInteractionEnabled = false
        btnSavedClaim.isUserInteractionEnabled = false

        if let bounty = self.bounty {
            SavedBountiesManager.remove(id: bounty.standardBountiesId)
        }

    }

    @IBAction func doStartWorkTap(_ sender: Any) {

        // If not connected to network
        if !NetworkReachability.shared.isConnected.value {

            SCLAlertView(appearance: gitcoinAppearance()).showWarning("You are not online", subTitle: "Please find a network before continuing.", closeButtonTitle: "DONE")

            return
        }

        // When usera swipes right for the first time without being signed in
        // pop alert.  Once show alert once via seenSwipeRightBountyAlert
        if  OctokitManager.shared.isSignedOut {

            let appearance = gitcoinAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)

            alertView.addButton("SIGN IN") {
                self.performSegue(withIdentifier: "webviewSegue", sender: nil)
            }

            alertView.addButton("CONTINUE BROWSING") {}

            alertView.showInfo("Sign In with Github", subTitle: "to get match email intros to this repo owner.")

            return
        }

        let user = OctokitManager.shared.user.value

        // The api is looking for + or -
        let mappedDirection =  "+"

        guard let bounty = self.bounty else { return }

        TrackingManager.shared.trackEvent(.didSwipeBounty(bounty: bounty, direction: mappedDirection, user: user))

        if let bounty = self.bounty, isBountyClaimed == true {

            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)

            alertView.addButton("No") {}
            alertView.addButton("YES") {

                let subscription = GitcoinAPIService.shared.provider.rx.request(.removeClaimed(bounty: bounty))
                    .subscribe { event in
                        switch event {
                        case .success:

                         SCLAlertView().showSuccess("Removed Bounty", subTitle: "You have successfully removed this bounty '\(bounty.title)'")

                        self.lblClaim.text = "REMOVED"
                        self.btnClaim.isUserInteractionEnabled = false
                        self.isBountyClaimed = false

                        case .error(let error):
                            logger.error(error)
                        }
                }
                self.disposeBag.insert(subscription)
            }

            alertView.showWarning("Remove Claimed Bounty", subTitle: "Do you really want to delete this bounty?")

        } else {
         let subscription = GitcoinAPIService.shared.provider.rx.request(.fundingSave(bounty: bounty, user: user, direction: mappedDirection))
            .subscribe { event in
                switch event {
                case .success:

                    // set the lastViewedBountyId after a successful action has been taken
                    // this will ensure the user only sees the bounties once
                    Defaults[UserDefaultKeyConstants.seenSwipeRightBountyAlert] = true
                    Defaults[UserDefaultKeyConstants.lastViewedBountyId] = bounty.id

                    logger.verbose("set lastViewedBountyId=\(Defaults[UserDefaultKeyConstants.lastViewedBountyId] ?? -1)")

                    SCLAlertView().showSuccess("Started Bounty", subTitle: "You have successfully claimed the bounty '\(bounty.title)'")

                    self.lblClaim.text = "STARTED WORK"
                    self.btnClaim.isUserInteractionEnabled = false
                    self.lblSavedStartWork.text = "STARTED WORK"
                    self.btnSavedClaim.isUserInteractionEnabled = false
                    self.btnUnsave.isUserInteractionEnabled = false
                    self.isBountyClaimed =  true

                    SavedBountiesManager.remove(id: bounty.standardBountiesId)

                case .error(let error):
                    logger.error(error)
                }
            }
            disposeBag.insert(subscription)

        }

    }

    func setPosted(_ bounty: Bounty) {
        lblPosted.text = "POSTED: \(bounty.createdAgo) - EXP. \(bounty.expiresIn)"
    }

    func setFunderInfo(_ bounty: Bounty) {

        var ownerGithubUsernameString = ""
        var bountyOwnerEmailString = ""
        var tokenValueString = ""
        var usdtDisplayValueString = ""

        lblFunderInfo.text = ""

        if let ownerGithubUsername = bounty.ownerGithubUsername, !ownerGithubUsername.isEmpty {
            ownerGithubUsernameString = "\(ownerGithubUsername) \n"
            lblFunderInfo.text?.append(ownerGithubUsernameString)
        }

        if let bountyOwnerEmail = bounty.bountyOwnerEmail, !bountyOwnerEmail.isEmpty {
            bountyOwnerEmailString = "\(bountyOwnerEmail) \n"
            lblFunderInfo.text?.append(bountyOwnerEmailString)
        }

        if !bounty.usdtDisplayValue.isEmpty {
            usdtDisplayValueString = "\(bounty.usdtDisplayValue) \n"
            lblFunderInfo.text?.append(usdtDisplayValueString)
        }

        if let tokenValue = bounty.tokenValueString, !tokenValue.isEmpty {
            tokenValueString = "\(tokenValue) \n"
            lblFunderInfo.text?.append(tokenValueString)
        }

    }

    func setIssueDesc(_ bounty: Bounty) {
        lblIssueDesc.text = bounty.descriptionText
    }

    func set(status: String?) {
        if let status = status {
            self.lblStatus.text = status.capitalized
        }
    }

    func set(title: String?) {
        if let title = title {
            self.lblTitle.text = title
        }
    }

    func set(imageUrl: String?) {
        if let imageUrl = imageUrl {
            Alamofire.request(imageUrl).responseImage { response in
                if let image = response.result.value {
                    let circularImage = image.af_imageRoundedIntoCircle()

                    self.avatarImageView.image = circularImage
                }
            }
        }
    }

    func set(keywords: [String]?) {

        guard let keywords = keywords else {
            return
        }

        tagsField.readOnly = true
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        keywordContainer.addSubview(tagsField)

        NSLayoutConstraint.activate([
            tagsField.topAnchor.constraint(equalTo: keywordContainer.topAnchor),
            tagsField.leadingAnchor.constraint(equalTo: keywordContainer.leadingAnchor),
            tagsField.trailingAnchor.constraint(equalTo: keywordContainer.trailingAnchor),
            tagsField.bottomAnchor.constraint(equalTo: keywordContainer.bottomAnchor)
            ])

        tagsField.addTags(keywords)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let isThisASavedBounty = SavedBountiesManager.bountyExists(id: bounty?.standardBountiesId)

        if indexPath.row == 1 && isThisASavedBounty {
            return 0
        }

        if indexPath.row == 2 && !isThisASavedBounty {
            return 0
        }

        return UITableViewAutomaticDimension
    }

}
