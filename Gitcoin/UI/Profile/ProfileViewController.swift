//
//  ProfileViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/15/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage
import Crashlytics
import SwiftyUserDefaults
import WSTagsField
import Octokit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var authButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var avatarImage: UIImageView!

    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var tagFieldViewContainer: UIView!
    
    let tagsField = WSTagsField()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTagField()
        
        observeUI()
        
        observeUser()
        
        Answers.logContentView(withName: "Profile", contentType: "View", contentId: nil)
    }

    func observeUI(){
        
        let doneButtonSubscription = doneButton.rx.tap.bind {
            self.dismiss(animated: true, completion: {
                Answers.logCustomEvent(withName: "Profile Done")
            })
        }
        
        disposeBag.insert(doneButtonSubscription)
        
        let authButtonSubscription = authButton.rx.tap.bind {
            if OctokitManager.shared.isSignedIn {
                
                OctokitManager.shared.signOut()
                
                Answers.logCustomEvent(withName: "Logout")
                
                return
            }
            
            let url = OctokitManager.shared.oAuthConfig.authenticate()
            
            Answers.logCustomEvent(withName: "Login")
            
            UIApplication.shared.open(url!, options: [:], completionHandler: { _ in
                
            })
        }
        
        disposeBag.insert(authButtonSubscription)
    }
    
    /// Observe User Object: This subscription listens for changes in the user instance
    /// So this will be called anytime time OctokitManager.shared.user
    /// is changed.  There by updating the ui base on the state of that
    /// user object
    func observeUser(){
        
        let subscription = OctokitManager.shared.user.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                
                // User logged in
                if let user = user {
                    
                    self?.populateTagsFromApiKeywords(with: user)
                    
                    if let name = user.name {
                        self?.nameLabel.text = "Hi, \(name)"
                    }
                    
                    self?.authButton.setTitle("Sign out",for: .normal)
                    
                    if let avatarUrl = user.avatarURL {
                        
                        Alamofire.request(avatarUrl).responseImage { response in
                            
                            if let image = response.result.value {
                                let circularImage = image.af_imageRoundedIntoCircle()
                                
                                self?.avatarImage.image = circularImage
                            }
                        }
                    }
                    // User logged out
                }else{
                    self?.nameLabel.text = "Hi, Bounty Hunter"
                    
                    // TODO: persist these defaults in one place, right now its in storyboard
                    self?.authButton.setTitle("Sign in",for: .normal)
                    
                    self?.avatarImage.image = #imageLiteral(resourceName: "guy1_black")
                }
            })
        
        disposeBag.insert(subscription)
    }
    
    fileprivate func setupTagField() {
        tagsField.backgroundColor = .black
        tagsField.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tagsField.spaceBetweenTags = 10.0
        tagsField.font = .systemFont(ofSize: 12.0)
        tagsField.tintColor = .green
        tagsField.textColor = .black
        tagsField.fieldTextColor = .blue
        tagsField.selectedColor = .black
        tagsField.selectedTextColor = .red
        tagsField.delimiter = ","
        
        // Events
        tagsField.onDidAddTag = { _ in
            print("DidAddTag")
        }
        
        tagsField.onDidRemoveTag = { _ in
            print("DidRemoveTag")
        }
        
        tagsField.onDidChangeText = { _, text in
            print("DidChangeText")
        }
        
        tagsField.onDidBeginEditing = { _ in
            print("DidBeginEditing")
        }
        
        tagsField.onDidEndEditing = { _ in
            print("DidEndEditing")
        }
        
        tagsField.onDidChangeHeightTo = { sender, height in
            print("HeightTo \(height)")
        }
        
        
        tagsField.placeholder = "Enter a tag"
        tagsField.backgroundColor = .white
        //        tagsField.frame = CGRect(x: 0, y: 0, width: 300, height: 44)
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        tagFieldViewContainer.addSubview(tagsField)
        
        
        NSLayoutConstraint.activate([
            tagsField.topAnchor.constraint(equalTo: tagFieldViewContainer.topAnchor),
            tagsField.leadingAnchor.constraint(equalTo: tagFieldViewContainer.leadingAnchor),
            tagsField.trailingAnchor.constraint(equalTo: tagFieldViewContainer.trailingAnchor),
            
        ])
    }
    
    func populateTagsFromApiKeywords(with user: User){
        _ = GitcoinAPIService.shared.provider.rx
            .request(.userKeywords(user: user))
            .filterSuccessfulStatusCodes()
            .map(to: UserKeywordResult.self)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] userKeywordResult in
                
                if let keywords = userKeywordResult.keywords {
                    for keyword in keywords {
                        self?.tagsField.addTag(keyword)
                    }
                }else{
                    
                }
                }, onError: { error in
                    
            })
    }
}
