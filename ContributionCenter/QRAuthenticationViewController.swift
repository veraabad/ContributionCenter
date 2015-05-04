//
//  QRAuthenticationViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/3/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class QRAuthenticationViewController: UIViewController {
    // Landscape: 
    // camera view
    @IBOutlet weak var cameraViewL: UIView!
    // image view for QR code
    @IBOutlet weak var qrImageViewL: UIImageView!
    // Portrait:
    // camera view
    @IBOutlet weak var cameraViewP: UIView!
    // image view for QR code
    @IBOutlet weak var qrImageViewP: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make sure landscape views are hidden
        showPortrait()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Setup to use front camera
    func setupCamera() {
        
    }
    
    // Hide landscape views
    func hideLandscape() {
        cameraViewL.hidden = true
        qrImageViewL.hidden = true
    }
    
    // Hide portrait views
    func hidePortrait() {
        cameraViewP.hidden = true
        qrImageViewP.hidden = true
    }
    
    // Show landscape views and hide portrait views
    func showLandscape() {
        cameraViewL.hidden = false
        qrImageViewL.hidden = false
        hidePortrait()
    }
    
    // Show portrait views and hide landscape views
    func showPortrait() {
        cameraViewP.hidden = false
        qrImageViewP.hidden = false
        hideLandscape()
    }
}
