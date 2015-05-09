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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup views
        setPortraitViews(cameraViewP, otherView: qrImageViewP)
        setLandscapeViews(cameraViewL, otherView: qrImageViewL)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
