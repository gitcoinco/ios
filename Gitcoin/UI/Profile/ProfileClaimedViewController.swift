//
//  ProfileClaimedViewController.swift
//  Gitcoin
//
//  Created by John Brunelle on 3/4/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit
import SCLAlertView

class ProfileClaimedViewController: UIViewController {
    
    var data: [Bounty]?
    @IBOutlet var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        var control: UIRefreshControl = UIRefreshControl()
        return control
    }()
    
    lazy internal var activityIndicator: UIActivityIndicatorView! = {
        return self.createActivityIndicator()
    }()
    
    @objc func loadClaimedList(){
        
        if !refreshControl.isRefreshing && (data?.count == 0 || data == nil){
            activityIndicator.startAnimating()
        }
        
        let user = OctokitManager.shared.user.value
        
        _ = GitcoinAPIService.shared.provider.rx.request(.claimedList(username: user?.login))
            .map(to: [Bounty].self)
            .subscribe { event in
                switch event {
                case .success(let claimed):
                    
                    logger.verbose("Bounties Claimed List: \(claimed)")
                    
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.stopAnimating()
                    
                    if claimed.count == 0{
                        self.showNoDataAlert()
                    }
                    
                    self.data = claimed
                    self.tableView.reloadData()
                    
                case .error(let error):
                    logger.error(error)
                    print("error = \(error)")
                }
        }
        
    }
    
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
        loadClaimedList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showNoDataAlert(){
        let appearance = gitcoinAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("CONTINUE") {}
        
        alertView.showInfo("Oh Snap, We could not find any claimed bounties for you", subTitle: "to show claimed bouties you must be signed in to Github and have claimed a bounty.")
    }
}

// MARK: - Table view delegate
extension ProfileClaimedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            
            
            alertView.addButton("No") {print("don't delete")}
            alertView.addButton("YES") {
                let bounty = self.data?[indexPath.row]

                self.activityIndicator.startAnimating()
                
                _ = GitcoinAPIService.shared.provider.rx.request(.removeClaimed(bounty: bounty))
                    .subscribe { event in
                        switch event {
                        case .success(_):

                            print("claimed deleted, bountty id = \(String(describing: bounty))")
                            self.loadClaimedList()

                        case .error(let error):
                            logger.error(error)
                        }
                }
            }
            
            alertView.showWarning("Delete Claimed Bounty", subTitle: "Do you really want to delete this bounty?")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

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
