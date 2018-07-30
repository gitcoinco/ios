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

class ProfileSavedViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        
        tableView.rowHeight = 90
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProfileClaimedCell", bundle: Bundle.main), forCellReuseIdentifier: "ProfileClaimedCell")
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.addSubview(self.refreshControl)
        refreshControl.addTarget(self, action: #selector(loadSavedList), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.stopAnimating()
        disposable?.dispose()
        noClaimedView.isHidden = true
        loadSavedList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TrackingManager.shared.trackEvent(.didViewSavedBounties)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        activityIndicator.stopAnimating()
        disposable?.dispose()
    }
    
    func showNoDataAlert(){
        
        noClaimedView.isHidden = false
    }
    
    @objc func loadSavedList(){
        
        if !refreshControl.isRefreshing && (data?.count == 0 || data == nil){
            activityIndicator.startAnimating()
        }
        
        if SavedBountiesManager.shared.currentIds().count == 0{
            self.activityIndicator.stopAnimating()
            self.data = []
            self.tableView.reloadData()
            self.showNoDataAlert()
        }
        else{
            disposable = GitcoinAPIService.shared.provider.rx.request(.bountyList(ids: SavedBountiesManager.list()))
                .map(to: [Bounty].self)
                .subscribe { event in
                    switch event {
                    case .success(let saved):
                        
                        logger.verbose("Bounties Saved List: \(saved)")
                        
                        self.refreshControl.endRefreshing()
                        self.activityIndicator.stopAnimating()
                        
                        if saved.count == 0{
                            self.showNoDataAlert()
                        }

                        self.data = saved
                        self.tableView.reloadData()
                        
                    case .error(let error):
                        logger.error(error)
                        print("error = \(error)")
                        self.activityIndicator.stopAnimating()
                        self.showNoDataAlert()
                    }

            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "savedDetailsSegue",
            let destination = segue.destination as? BountyDetailsContainerViewController,
            let bounty = sender as? Bounty{
            
            destination.bounty = bounty
        }
    }
}
    
// MARK: - Table view delegate
extension ProfileSavedViewController: UITableViewDelegate {
    
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
                
                SavedBountiesManager.remove(id: bounty?.standardBountiesId)
                self.loadSavedList()
            }

            alertView.showWarning("Delete Saved Bounty", subTitle: "Do you really want to delete this bounty?")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bounty = self.data?[indexPath.row]
        
        performSegue(withIdentifier: "savedDetailsSegue", sender: bounty)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Table view data source
extension ProfileSavedViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let bounties = self.data{
            return bounties.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProfileClaimedCell", for: indexPath) as! ProfileClaimedCell
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        if let bounties = self.data{
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
