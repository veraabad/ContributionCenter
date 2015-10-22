//
//  QRBaseViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/6/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit
import AVFoundation

class QRBaseViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // Landscape:
    // camera view
    var cameraViewLandscape: UIView!
    // Camera view constraints
    var cameraLandscapeRightTop: [NSLayoutConstraint] = []
    var cameraLandscapeRightTrailing: [NSLayoutConstraint] = []
    var cameraLandscapeLeftHeight: [NSLayoutConstraint] = []
    // other view to use
    var otherViewLandscape: UIView?
    // Other view constraints
    var otherViewLandscapeRightHeight: [NSLayoutConstraint] = []
    var otherViewLandscapeLeftTop: [NSLayoutConstraint] = []
    var otherViewLandscapeLeftTrailing:[NSLayoutConstraint] = []
    
    // Height from top
    var topHeight:String!
    
    // Landscape Bools
    var landscapeRight = false
    var landscapeLeft = false
    
    // Portrait:
    // camera view
    var cameraViewPortrait: UIView!
    // other view to use
    var otherViewPortrait: UIView?
    
    // camera view holder
    var cameraViewHolder:UIView!
    // other view holder
    var otherViewHolder:UIView?
    
    // UIButton to flip the camera to front or back
    @IBOutlet weak var cameraFlipBttn:UIButton!
    var flipBool = false
    
    // Camera variables
    var captureSession = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    let captureMetadataOutput = AVCaptureMetadataOutput()
    
    // If camera found, store it here
    var captureDeviceFront:AVCaptureDevice?
    var captureDeviceBack:AVCaptureDevice?
    var previewLayerConnection:AVCaptureConnection?
    
    // Frame for QR
    var qrFrameView:UIView!
    let qrBorderColor = UIColor.blueColor().CGColor
    let borderWidth:CGFloat! = 2
    
    // Holds String response from QR code
    //var qrResponse:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        cameraViewLandscape.translatesAutoresizingMaskIntoConstraints = false
        otherViewLandscape?.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDict = ["cameraViewLandscape": cameraViewLandscape, "otherViewLandscape": otherViewLandscape]
        
        // Set constraints for landscape right
        cameraLandscapeRightTop = NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(topHeight)-[cameraViewLandscape(==otherViewLandscape)]|", options: NSLayoutFormatOptions.AlignAllBottom, metrics: nil, views: viewsDict)
        
        cameraLandscapeRightTrailing = NSLayoutConstraint.constraintsWithVisualFormat("H:|[cameraViewLandscape][otherViewLandscape(==cameraViewLandscape)]|", options: NSLayoutFormatOptions.AlignAllBottom, metrics: nil, views: viewsDict)
        
        otherViewLandscapeRightHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[otherViewLandscape(==cameraViewLandscape)]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
        
        // Set constraints for landscape left
        otherViewLandscapeLeftTrailing = NSLayoutConstraint.constraintsWithVisualFormat("H:|[otherViewLandscape][cameraViewLandscape(==otherViewLandscape)]|", options: NSLayoutFormatOptions.AlignAllBottom, metrics: nil, views: viewsDict)
        
        otherViewLandscapeLeftTop = NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(topHeight)-[otherViewLandscape(==otherViewLandscape)]|", options: NSLayoutFormatOptions.AlignAllBottom, metrics: nil, views: viewsDict)
        
        cameraLandscapeLeftHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[cameraViewLandscape(==otherViewLandscape)]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
        
        // Find orientation of view controller
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait:
            print("Portrait")
            showPortrait()
            
        case .LandscapeLeft:
            print("LandscapeLeft")
            showLandscapeLeft()
            
        case .LandscapeRight:
            print("LandscapeRight")
            showLandscapeRight()
            
        default:
            print("Not a supported orientation")
        }
    }
    
    // MARK
    // View handlers for either portrait or landscape orientation
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if toInterfaceOrientation == .Portrait {
            showPortrait()
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        }
        else if toInterfaceOrientation == .LandscapeLeft {
            showLandscapeLeft()
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        }
        else if toInterfaceOrientation == .LandscapeRight {
            showLandscapeRight()
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        }
    }
    
    // Reset bounds of preview layer once everything is set
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updatePreviewLayer()
    }
    
    // Set Landscape views
    func setLandscapeViews(cameraView: UIView, otherView: UIView) {
        cameraViewLandscape = cameraView
        otherViewLandscape = otherView as UIView
    }
    
    // Set Portrait views
    func setPortraitViews(cameraView: UIView, otherView:UIView) {
        cameraViewPortrait = cameraView
        otherViewPortrait = otherView as UIView
    }
    
    // Hide landscape views
    func hideLandscape() {
        cameraViewLandscape.hidden = true
        otherViewLandscape?.hidden = true
    }
    
    // Hide portrait views
    func hidePortrait() {
        cameraViewPortrait.hidden = true
        otherViewPortrait?.hidden = true
    }
    
    // Show landscape views and hide portrait views
    func showLandscapeRight() {
        hidePortrait()
        cameraViewLandscape.hidden = false
        cameraViewHolder = cameraViewLandscape
        otherViewLandscape?.hidden = false
        otherViewHolder = otherViewLandscape
        
        // if view in landscape left then flip
        print("Landscape right called")
        self.view.layoutIfNeeded()
        if landscapeLeft {
            self.view.removeConstraints(otherViewLandscapeLeftTrailing)
            self.view.removeConstraints(otherViewLandscapeLeftTop)
            self.view.removeConstraints(cameraLandscapeLeftHeight)
            landscapeLeft = false
        }
        self.view.addConstraints(cameraLandscapeRightTrailing)
        self.view.addConstraints(cameraLandscapeRightTop)
        self.view.addConstraints(otherViewLandscapeRightHeight)
        self.view.layoutIfNeeded()
        landscapeRight = true
    }
    
    func showLandscapeLeft() {
        hidePortrait()
        cameraViewLandscape.hidden = false
        cameraViewHolder = cameraViewLandscape
        otherViewLandscape?.hidden = false
        otherViewHolder = otherViewLandscape
        
        // if view in landscape left then flip
        print("Landscape left called")
        self.view.layoutIfNeeded()
        if landscapeRight {
            self.view.removeConstraints(cameraLandscapeRightTrailing)
            self.view.removeConstraints(cameraLandscapeRightTop)
            self.view.removeConstraints(otherViewLandscapeRightHeight)
            landscapeRight = false
        }
        self.view.addConstraints(otherViewLandscapeLeftTrailing)
        self.view.addConstraints(otherViewLandscapeLeftTop)
        self.view.addConstraints(cameraLandscapeLeftHeight)
        self.view.layoutIfNeeded()
        landscapeLeft = true
    }
    
    // Show portrait views and hide landscape views
    func showPortrait() {
        hideLandscape()
        cameraViewPortrait.hidden = false
        cameraViewHolder = cameraViewPortrait
        otherViewPortrait?.hidden = false
        otherViewHolder = otherViewPortrait
        self.view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK
    // Camera functions
    
    // Find any cameras on device
    func findCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through devices until we find front facing camera
        // if one is here
        for device in devices {
            // Make sure it supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm its the front camera
                if (device.position == AVCaptureDevicePosition.Front) {
                    captureDeviceFront = device as? AVCaptureDevice
                    if captureDeviceFront != nil && captureDeviceBack != nil {
                        print("Front camera found")
                        self.setupCamera()
                    }
                }
                if (device.position == AVCaptureDevicePosition.Back) {
                    captureDeviceBack = device as? AVCaptureDevice
                    if captureDeviceFront != nil && captureDeviceBack != nil {
                        print("Front camera found")
                        self.setupCamera()
                    }
                }
            }
        }
    }
    
    // Setup to use front camera
    func setupCamera() {
        let err:NSError? = nil
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDeviceFront))
        } catch {
            print(error)
        }
        
        
        
        // print error if one is present
        if err != nil {
            print("error : \(err?.localizedDescription)")
        }
        
        // setup AVCaptureMetadataOutput
        captureSession.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Add camera layer to view
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        setPreview()
        // Start video capture
        captureSession.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrFrameView.frame = CGRectZero
            print("No QR code is detected")
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equel to the QR code metadata then lets get the info from it
            let barCodeObject = previewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            // UPDATE qrFrame here
            qrFrameView.frame = barCodeObject.bounds
            
            // print the string info in the qr code
            if metadataObj.stringValue != nil {
                print("QR Code: \(metadataObj.stringValue)")
                //self.qrResponse = metadataObj.stringValue
                obtainRespon(metadataObj.stringValue)
            }
        }
    }
    
    func obtainRespon(qrResponse: String) {
        // Do what needs to be done with response
    }
    
    func setupQRFrameView() {
        qrFrameView = UIView()
        qrFrameView.layer.borderColor = qrBorderColor
        qrFrameView.layer.borderWidth = borderWidth
        cameraViewHolder?.addSubview(qrFrameView)
        cameraViewHolder?.bringSubviewToFront(qrFrameView)
    }
    
    // Remove previewlayer from super layer
    func updatePreviewLayer() {
        previewLayer?.removeFromSuperlayer()
        setPreview()
    }
    
    func setPreview() {
        if previewLayer != nil {
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer?.frame = self.cameraViewHolder.bounds
            previewLayer?.position = CGPointMake(CGRectGetMidX(cameraViewHolder.bounds), CGRectGetMidY(cameraViewHolder.bounds))
            self.cameraViewHolder?.layer.addSublayer(previewLayer!)
        }
    }
    
    // Flip camera if pressed
    @IBAction func flipCameraBttnAction(sender:UIButton) {
        var error:NSError? = nil
        if flipBool {
            captureSession.stopRunning()
            do {
                try captureSession.removeInput(AVCaptureDeviceInput(device: captureDeviceBack))
                try captureSession.addInput(AVCaptureDeviceInput(device: captureDeviceFront))
            } catch {
                print(error)
            }
            captureSession.startRunning()
            cameraFlipBttn.titleLabel?.text = "Back"
            flipBool = false
        }
        else {
            captureSession.stopRunning()
            do {
                    try captureSession.removeInput(AVCaptureDeviceInput(device: captureDeviceFront))
                    try captureSession.addInput(AVCaptureDeviceInput(device: captureDeviceBack))
            } catch {
                print(error)
            }
            captureSession.startRunning()
            cameraFlipBttn.titleLabel?.text = "Front"
            flipBool = true
        }
        
        
    }
   
}
