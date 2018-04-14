//
//  ProfileClaimedViewController.swift
//  Gitcoin
//
//  Created by John Brunelle on 3/4/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit

class ProfileClaimedViewController: UIViewController {
    
    var data: [Bounty]?
    @IBOutlet var tableView: UITableView!
    
    func loadClaimedList(){
        
        let user = OctokitManager.shared.user.value
        
        _ = GitcoinAPIService.shared.provider.rx.request(.claimedList(username: user?.login))
            .map(to: [Bounty].self)
            .subscribe { event in
                switch event {
                case .success(let claimed):
                    
                    print("claimed = \(claimed.count)")
                    logger.verbose("Bounties Claimed List: \(claimed)")
                    
                    self.data = claimed
                    self.tableView.reloadData()
                    
                case .error(let error):
                    logger.error(error)
                    print("error = \(error)")
                }
        }
        
    }
    
    override func viewDidLoad() {
        
        loadClaimedList()
        
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProfileClaimedCell", bundle: Bundle.main), forCellReuseIdentifier: "ProfileClaimedCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Table view delegate
extension ProfileClaimedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let bounty = self.data?[indexPath.row]

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
        cell.selectionStyle = .gray

        if let bounties = self.data{
            let title =  bounties[indexPath.row].title
            cell.set(title: title)
            return cell
        }
        
        return ProfileClaimedCell()
    }


}
