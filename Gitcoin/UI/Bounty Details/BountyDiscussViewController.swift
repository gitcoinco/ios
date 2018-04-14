//
//  BountyDiscussViewController.swift
//  Gitcoin
//
//  Created by John Brunelle on 3/4/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyUserDefaults
import Octokit

class BountyDiscussViewController: UIViewController {
    
    var bounty: Bounty?
    var data: [Issue]?
    let disposeBag = DisposeBag()
    let cellSpacingHeight: CGFloat = 15
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var discussView: BountyDiscussView!
    //@IBOutlet var composerBar: PHFComposeBarView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeIssue()
        
        //OctokitManager.shared.bountyIssues(issueId: 760)
        
        //OctokitManager.shared.addComment(issueId: 760,  comment: "This is a test comment and can be deleted")
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "BountyCommentCell", bundle: Bundle.main), forCellReuseIdentifier: "BountyCommentCell")
        
        if let bounty = bounty{
            OctokitManager.shared.issueComments(issueId: bounty.githubIssueNumber)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func observeIssue(){
        
        let subscription = OctokitManager.shared.comments.asObservable()
            .observeOn(MainScheduler.instance)
            .ignoreNil()
            .subscribe(onNext: { [weak self] comments in
                
                self?.data = comments
                self?.tableView.reloadData()
                
            })
        
        disposeBag.insert(subscription)
    }

}


// MARK: - Table view delegate
extension BountyDiscussViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
        
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let comments = self.data{
            
            return comments.count
        }
        return 0
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "BountyCommentCell", for: indexPath) as! BountyCommentCell
      
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1

    
        if let comments = self.data{
            
            let comment =  comments[indexPath.section]
                
            if let user = comment.user?.login, let createdAt = comment.createdAt{
                cell.set(user: user, createdOn: createdAt)
            }
            
            if let body = comment.body{
                cell.set(comment: body)
            }
            
            return cell
        }
        
        return BountyCommentCell()
    }
    
    
}
