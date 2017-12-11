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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playerView.load(withVideoId: "DJartWzDn0E")
        
        TrackingManager.shared.trackEvent(.didViewInfo)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        TrackingManager.shared.trackEvent(.didCloseInfo)
    }
}
