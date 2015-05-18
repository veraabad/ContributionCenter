//
//  QRAuthenticationViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/3/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit
import AVFoundation

class QRAuthenticationViewController: QRBaseViewController {
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
    
    // QR code generator
    var qrGenerator: QRGenerator!
    
    // If there is a parent view then save it here
    var parentVC:AVSideBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup views
        setPortraitViews(cameraViewP, otherView: qrImageViewP)
        setLandscapeViews(cameraViewL, otherView: qrImageViewL)
        
        if let vc = self.navigationController?.parentViewController as? AVSideBarController {
            // Save instance of parentViewController
            println("QR has parent")
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
        // Generate QR code
        produceQRCode()
    }
    
    // Generate QR code and place in image view
    func produceQRCode() {
        var imageView = otherViewHolder as! UIImageView
        var scale:CGFloat! = imageView.image?.scale
        // Obtain QR code to show
        qrGenerator = QRGenerator(qrString: "Abad Vera", sizeRate: scale)
        
        // Show QR Code
        imageView.image = qrGenerator.qrImage
    }
    
    // If turned then show QR here
    override func showLandscapeLeft() {
        super.showLandscapeLeft()
        qrImageViewL.image = qrGenerator.qrImage
    }
    // If turned the show QR here
    override func showLandscapeRight() {
        super.showLandscapeRight()
        qrImageViewL.image = qrGenerator.qrImage
    }
    
    override func obtainRespon(qrResponse: String) {
        if qrResponse == "" {
            return
        }
        else {
            if qrResponse == "Abad Vera" {
                captureSession.stopRunning()
                println("Success")
                var vc = self.storyboard?.instantiateViewControllerWithIdentifier("AuthenticatedVC") as! AuthenticatedViewController
                self.showViewController(vc, sender: self)
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
