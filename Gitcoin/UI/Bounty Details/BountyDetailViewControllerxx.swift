//
//  BountyDetailViewController.swift
//  Gitcoin
//
//  Created by John Brunelle on 3/4/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit

class BountyDetailViewControllerxx: UIViewController {
    
    var bounty: Bounty?
    @IBOutlet weak var detailView: BountyDetailView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let bounty = bounty else { return }
        detailView.populate(with: bounty)
    }
}
