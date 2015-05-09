//
//  MenuViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/7/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    // To hold instance of parent view controller
    var parentVC: AVSideBarController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if we have a parent VC
        if let parent = self.parentViewController as! AVSideBarController! {
            // Hold instance of parent view controller
            parentVC = parent
            // On startup load first view controller
            var vc = self.storyboard?.instantiateViewControllerWithIdentifier("AuthenticationVC") as? QRAuthenticationViewController
            parentVC.addVC(vc!)
            parentVC.showCurrentVC()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
