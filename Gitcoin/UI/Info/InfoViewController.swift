//
//  InfoViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/15/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import youtube_ios_player_helper

class InfoViewController: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var versionText = ""
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionText = "Version \(version) "
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionText = "\(versionText)Build \(version)"
        }
        
        self.versionLabel.text = versionText
        
        playerView.delegate = self

        playerView.load(withVideoId: "DJartWzDn0E")
    }
    
    override func viewWillLayoutSubviews() {
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TrackingManager.shared.trackEvent(.didViewInfo)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        TrackingManager.shared.trackEvent(.didCloseInfo)
    }
}

extension InfoViewController: YTPlayerViewDelegate{
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == YTPlayerState.playing {
            TrackingManager.shared.trackEvent(.didPlayWhatIsGitCoinVideo)
        }
    }
}
