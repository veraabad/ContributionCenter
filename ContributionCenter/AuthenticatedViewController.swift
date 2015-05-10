//
//  AunthenticatedViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/2/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

// View Controller to show a simple view for a few seconds after user has been logged in
class AuthenticatedViewController: UIViewController {
    
    // Show image depending on type of authentication
    @IBOutlet weak var authenticatedImageView: UIImageView!
    
    // holds what device this is
    var deviceInterface:UIUserInterfaceIdiom!
    
    // Show view for this amount of secons
    var delaySec = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // First find out if device is iphone or ipad
        deviceInterface = UIDevice.currentDevice().userInterfaceIdiom
        // Set uiimage with white tint
        authenticatedImageView.tintColor = UIColor.whiteColor()
    }
    
    // Setup authentication image according to device
    override func viewWillAppear(animated: Bool) {
        var img:UIImage!
        if deviceInterface == .Phone {
            img = UIImage(named: "Fingerprint")
        }
        else if deviceInterface == .Pad {
            img = UIImage(named: "Checkmark")
        }
        authenticatedImageView.image = img.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    }
    
    // Only show view for 5 seconds
    override func viewDidAppear(animated: Bool) {
        let delay = Double(delaySec) * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            println("Timer up")
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SideBarController") as! AVSideBarController
            self.showViewController(vc, sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
