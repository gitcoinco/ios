//
//  SideMenuNavigationController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/5/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import SideMenu
import Octokit

class SideMenuNavigationController: UISideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appScreenRect = UIApplication.shared.keyWindow?.bounds ?? UIWindow().bounds
        
        // Do any additional setup after loading the view.
        self.menuWidth = max(round(min((appScreenRect.width), (appScreenRect.height)) * 0.70), 240)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}
