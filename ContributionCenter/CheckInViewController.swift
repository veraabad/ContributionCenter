//
//  CheckInViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/10/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class CheckInViewController: QRBaseViewController {
    // Portait:
    // InfoView
    @IBOutlet weak var infoViewP: UIView!
    // Camera View
    @IBOutlet weak var cameraViewP: UIView!
    // Label to show the name of the person in
    @IBOutlet weak var nameLabelP: UILabel!
    
    // Landscape:
    // Info view
    @IBOutlet weak var infoViewL: UIView!
    // Camera view
    @IBOutlet weak var cameraViewL: UIView!
    
    // If there is a parent view then save it here
    var parentVC:AVSideBarController!
    
    var delaySec = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup views
        setPortraitViews(cameraViewP, otherView: infoViewP)
        setLandscapeViews(cameraViewL, otherView: infoViewL)
        
        // Make sure nameLabel is cleared
        nameLabelP.text = ""
        
        // Check for instance of parent and setup navController
        if let vc = self.navigationController?.parentViewController as? AVSideBarController {
            // Save instance of parentViewController
            println("Check in has parent")
            parentVC = vc
            // Have a clear background for UINavigationController
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.translucent = true
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            
            // Navigation item on the right for
            var rightItem = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .Plain, target: self, action: Selector("showMenuAction"))
            self.navigationItem.leftBarButtonItem = rightItem
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // Find camera and start it up
        findCamera()
        previewLayerConnection = previewLayer?.connection
        setupQRFrameView()
    }
    
    override func obtainRespon(qrResponse: String) {
        if qrResponse == "" {
            return
        }
        else {
            nameLabelP.text = qrResponse
            captureSession.stopRunning()
            let delay = Double(delaySec) * Double(NSEC_PER_MSEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                println("Camera running again")
                self.qrFrameView.frame = CGRectZero // Removes the qrFrameView from sight once camera starts up again
                self.captureSession.startRunning()
            }
        }
    }
    
    func showMenuAction() {
        println("Menu called")
        if parentVC != nil {
            parentVC.showMenu()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
