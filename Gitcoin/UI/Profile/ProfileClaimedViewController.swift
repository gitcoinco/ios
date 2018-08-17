//
//  ProfileClaimedViewController.swift
//  Gitcoin
//
//  Created by John Brunelle on 3/4/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit
import SCLAlertView
import RxSwift

class ProfileClaimedViewController: UIViewController {

    var data: [Bounty]?
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var noClaimedView: UIView!

    lazy var refreshControl: UIRefreshControl = {
        var control: UIRefreshControl = UIRefreshControl()
        return control
    }()

    lazy internal var activityIndicator: UIActivityIndicatorView! = {
        return self.createActivityIndicator()
    }()

    var disposable: Disposable?
    var didShowSigninDialog = false

    override func viewDidLoad() {

        tableView.rowHeight = 90
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProfileClaimedCell", bundle: Bundle.main), forCellReuseIdentifier: "ProfileClaimedCell")
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.addSubview(self.refreshControl)
        refreshControl.addTarget(self, action: #selector(loadClaimedList), for: .valueChanged)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        activityIndicator.stopAnimating()
        disposable?.dispose()
        loadClaimedList()

        noClaimedView.isHidden = true

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        TrackingManager.shared.trackEvent(.didViewClaimedBounties)

        if  OctokitManager.shared.isSignedOut &&
            topMostViewController().isKind(of: ProfileClaimedViewController.self) &&
            didShowSigninDialog == false {

            didShowSigninDialog = true

            let appearance = gitcoinAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)

            alertView.addButton("SIGN IN") {
                self.performSegue(withIdentifier: "webviewSegue", sender: nil)
            }

            alertView.addButton("CONTINUE BROWSING") {}

            alertView.showInfo("Sign In with Github", subTitle: "To see your listing of claimed bounties")

        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        activityIndicator.stopAnimating()
        disposable?.dispose()
    }

    func showNoDataAlert() {

        noClaimedView.isHidden = false
//        let appearance = gitcoinAppearance(
//            showCloseButton: false
//        )
//        let alertView = SCLAlertView(appearance: appearance)
//
//        alertView.addButton("CONTINUE") {}
//
//        alertView.showWarning("Oh Snap, We could not find any claimed bounties for you", subTitle: "to show claimed bouties you must be signed in to Github and have claimed a bounty.")
    }

    @objc func loadClaimedList() {

        if !refreshControl.isRefreshing && (data?.count == 0 || data == nil) {
            activityIndicator.startAnimating()
        }

        let user = OctokitManager.shared.user.value

        disposable = GitcoinAPIService.shared.provider.rx.request(.claimedList(username: user?.login))
            .map(to: [Bounty].self)
            .subscribe { event in
                switch event {
                case .success(let claimed):

                    logger.verbose("Bounties Claimed List: \(claimed)")

                    self.refreshControl.endRefreshing()
                    self.activityIndicator.stopAnimating()

                    if claimed.count == 0 {
                        self.showNoDataAlert()
                    }

                    self.data = claimed
                    self.tableView.reloadData()

                    // just in case the feed side claimed bounties somehow gets out of synch with the saved local bounties
                    SavedBountiesManager.removeByList(of: claimed)

                case .error(let error):
                    logger.error(error)
                    print("error = \(error)")
                    self.activityIndicator.stopAnimating()

                }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "claimedDetailsSegue",
            let destination = segue.destination as? BountyDetailsContainerViewController,
            let bounty = sender as? Bounty {

            destination.bounty = bounty
            destination.isBountyClaimed = true
        } else if segue.identifier == "webviewSegue",
            let destination = segue.destination as? WebViewController {

            destination.title = "SIGN IN"

            destination.currentURL = OctokitManager.shared.oAuthConfig.authenticate()
        }
    }

//    fileprivate func whitespaceString(font: UIFont = UIFont.systemFont(ofSize: 15), width: CGFloat) -> String {
//        let kPadding: CGFloat = 20
//        let mutable = NSMutableString(string: "")
//        let attribute = [NSAttributedStringKey.font: font]
//        while mutable.size(withAttributes: attribute).width < width - (2 * kPadding) {
//            mutable.append(" ")
//        }
//        return mutable as String
//    }
}

// MARK: - Table view delegate
extension ProfileClaimedViewController: UITableViewDelegate {

//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let kCellActionWidth = CGFloat(70.0)// The width you want of delete button
//        let kCellHeight = tableView.frame.size.height // The height you want of delete button
//        let whitespace = whitespaceString(width: kCellActionWidth) // add the padding
//
//
//        let deleteAction = UITableViewRowAction(style: .`default`, title: whitespace) {_,_ in
//            // do whatever the action you want
//            let appearance = SCLAlertView.SCLAppearance(
//                showCloseButton: false
//            )
//            let alertView = SCLAlertView(appearance: appearance)
//
//
//            alertView.addButton("No") {print("don't delete")}
//            alertView.addButton("YES") {
//                let bounty = self.data?[indexPath.row]
//
//                self.activityIndicator.startAnimating()
//
//                _ = GitcoinAPIService.shared.provider.rx.request(.removeClaimed(bounty: bounty))
//                    .subscribe { event in
//                        switch event {
//                        case .success(_):
//
//                            print("claimed deleted, bountty id = \(String(describing: bounty))")
//                            self.loadClaimedList()
//
//                            if let bounty = bounty{
//                                TrackingManager.shared.trackEvent(GitcoinEvent.didRemoveClaimedBounty(bounty: bounty))
//                            }
//
//
//                        case .error(let error):
//                            logger.error(error)
//                        }
//                }
//            }
//
//            alertView.showWarning("Delete Claimed Bounty", subTitle: "Do you really want to delete this bounty?")
//        }
//
//        // create a color from patter image and set the color as a background color of action
//        let view = UIView(frame: CGRect(x: tableView.frame.size.width-70, y: 0, width: 70, height: kCellHeight))
//        view.backgroundColor = UIColor(red:235/255, green:242/255, blue:234/255, alpha:1.00) // background color of view
//        let imageView = UIImageView(frame: CGRect(x: 15,
//                                                  y: 20,
//                                                  width: 40,
//                                                  height: 40))
//        imageView.image = UIImage(named: "leftIcon")! // required image
//        view.addSubview(imageView)
//        let image = view.image()
//
//        deleteAction.backgroundColor = UIColor.init(patternImage: image)
//        return [deleteAction]
//
//    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)

            alertView.addButton("No") {}
            alertView.addButton("YES") {
                let bounty = self.data?[indexPath.row]

                self.activityIndicator.startAnimating()

                _ = GitcoinAPIService.shared.provider.rx.request(.removeClaimed(bounty: bounty))
                    .subscribe { event in
                        switch event {
                        case .success:

                            self.loadClaimedList()

                        case .error(let error):
                            logger.error(error)
                        }
                }
            }

            alertView.showWarning("Remove Claimed Bounty", subTitle: "Do you really want to delete this bounty?")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let bounty = self.data?[indexPath.row]

        performSegue(withIdentifier: "claimedDetailsSegue", sender: bounty)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Table view data source
extension ProfileClaimedViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let bounties = self.data {
            return bounties.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProfileClaimedCell", for: indexPath) as! ProfileClaimedCell
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

        if let bounties = self.data {
            let title =  bounties[indexPath.row].title
            let avatarUrl =  bounties[indexPath.row].avatarUrl

            cell.set(title: title)
            cell.set(imageUrl: avatarUrl)
            cell.set(details: bounties[indexPath.row])

            return cell
        }

        return ProfileClaimedCell()
    }

}
