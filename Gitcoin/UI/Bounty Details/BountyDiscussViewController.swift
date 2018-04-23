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
import SCLAlertView
import InputBarAccessoryView

class BountyDiscussViewController: UIViewController {
    
    var bounty: Bounty?
    var data: [Issue]?
    let disposeBag = DisposeBag()
    let cellSpacingHeight: CGFloat = 15
    
    @IBOutlet var tableView: UITableView!
    
    var currentText = ""
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var messageView: UIView!
    
    lazy var bar: InputBarAccessoryView = { [weak self] in
        let bar = InputBarAccessoryView()
        bar.delegate = self
        return bar
        }()

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var inputAccessoryView: UIView? {
        return bar
    }
    
    var didPostComment = false
    
    lazy var refreshControl: UIRefreshControl = {
        var control: UIRefreshControl = UIRefreshControl()
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        observeIssue()
    
        tableView.estimatedRowHeight = 300.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "BountyCommentCell", bundle: Bundle.main), forCellReuseIdentifier: "BountyCommentCell")
        
        tableView.addSubview(self.refreshControl)
        refreshControl.addTarget(self, action: #selector(loadIssueComments), for: .valueChanged)

        textField.inputView = bar
        resetInputBar()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        didPostComment = false
        loadIssueComments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
        view.endEditing(true)
        
        if  OctokitManager.shared.isSignedOut{
            
            bar.inputTextView.isUserInteractionEnabled = false
            
            let appearance = gitcoinAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            
            alertView.addButton("CLOSE") {}
            
            alertView.showInfo("Sign In with Github", subTitle: "The discussion can not begin until you are signed into Github")
        }
        
    }
    
    @objc func loadIssueComments(){
        if let bounty = bounty{
            print("issue number = \(String(describing:  bounty.githubIssueNumber))")
            OctokitManager.shared.issueComments(issueId: bounty.githubIssueNumber, repoName: bounty.githubRepoName, orgName: bounty.githubOrgName)
        }
    }

    func observeIssue(){
        
        let subscription = OctokitManager.shared.comments.asObservable()
            .observeOn(MainScheduler.instance)
            .ignoreNil()
            .subscribe(onNext: { [weak self] comments in
                
                print("comments.count = \(comments.count)")
                
                if comments.count > 0{
                   self?.messageView.isHidden = true
                }
                else{
                    self?.messageView.isHidden = false
                }
                self?.refreshControl.endRefreshing()
                
                self?.data = comments
                self?.tableView.reloadData()
                self?.scrollToBottom()
                
                if let didPostComment = self?.didPostComment, didPostComment == true{
                    SCLAlertView().showSuccess("Comment Successfully Posted", subTitle: "Tho it may take a little bit to actual show in this list.")
                    self?.currentText = ""
                    self?.bar.inputTextView.text = self?.currentText
                }
                
                self?.didPostComment = false
                
            }, onError: { (error) in
                
                self.refreshControl.endRefreshing()
                
                SCLAlertView().showError("Comment Fetching Problem", subTitle: "There was a problem in retrieving the comments, please try again later.")
                
            }, onCompleted: {
                
                self.refreshControl.endRefreshing()
                
            })
        
        disposeBag.insert(subscription)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        resetInputBar()
    }
    
    func resetInputBar() {
        bar.inputTextView.resignFirstResponder()
        bar.inputManagers.removeAll()
        let newBar = InputBarAccessoryView()
        newBar.delegate = self
        bar = newBar
        bar.inputTextView.text = currentText
        reloadInputViews()
    }
    
    func scrollToBottom(){
        
        if didPostComment{
            DispatchQueue.main.async {
                
                if let comments = self.data, comments.count > 0{
                    let indexPath = IndexPath(row: 0, section: comments.count-1)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
}

// MARK: - Table view delegate
extension BountyDiscussViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if let comments = self.data{
            
            let comment =  comments[indexPath.section]
            
            if let commentLogin = comment.user?.login,
                let userLogin = OctokitManager.shared.user.value?.login,
                commentLogin == userLogin,
                editingStyle == .delete{

                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    
                    alertView.addButton("No") {print("don't delete")}
                    alertView.addButton("YES") {
                        print("do delete for comment id = \(comment.id)")

                        if let bounty = self.bounty{
                            OctokitManager.shared.deleteComment(commentId: comment.id, repoName: bounty.githubRepoName, orgName: bounty.githubOrgName)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.loadIssueComments()
                            }
                        }
                    }
                    
                alertView.showWarning("Delete This Comment", subTitle: "Do you really want to delete this comment? Note: it takes a few to not show in this listing")
            }
        }
 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if let comments = self.data{
            
            let comment =  comments[indexPath.section]
        
            if let commentLogin = comment.user?.login,
                let userLogin = OctokitManager.shared.user.value?.login,
                commentLogin == userLogin{
                
                return true
            }
        }
        
        return false
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
                
                if let commentLogin = comment.user?.login,
                    let userLogin = OctokitManager.shared.user.value?.login,
                    commentLogin == userLogin{
                
                    cell.accessoryType = .disclosureIndicator
                    cell.tintColor = .black
                    cell.backgroundColor = UIColor(red: 204/255, green: 221/255, blue: 201/255, alpha: 1)
                    
                    cell.set(user: "You", createdOn: createdAt)
                }
                else{
                    cell.accessoryType = .none
                    cell.set(user: user, createdOn: createdAt)
                }
                
            }
            
            if let body = comment.body{
                cell.set(comment: body)
            }
            
            return cell
        }
        
        return BountyCommentCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension BountyDiscussViewController: InputBarAccessoryViewDelegate {
    
    // MARK: - InputBarAccessoryViewDelegate
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        view.endEditing(true)
        resetInputBar()
        
        if let bounty = bounty{
            OctokitManager.shared.addComment(issueId: bounty.githubIssueNumber, repoName: bounty.githubRepoName, orgName: bounty.githubOrgName, comment: text)
        
            didPostComment = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadIssueComments()
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String){
        currentText = text
    }
}

    

