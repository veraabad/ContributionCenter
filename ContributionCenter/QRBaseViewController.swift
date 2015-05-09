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
    // other view to use
    var otherViewLandscape: UIView?
    
    // Portrait:
    // camera view
    var cameraViewPortrait: UIView!
    // other view to use
    var otherViewPortrait: UIView?
    
    // camera view holder
    var cameraViewHolder:UIView!
    // other view holder
    var otherViewHolder:UIView?
    
    // Camera variables
    let captureSession = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    let captureMetadataOutput = AVCaptureMetadataOutput()
    
    // If camera found, store it here
    var captureDevice:AVCaptureDevice?
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
        // Find orientation of view controller
        
        
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait:
            println("Portrait")
            showPortrait()
            
        case .LandscapeLeft:
            println("LandscapeLeft")
            showLandscapeLeft()
            
        case .LandscapeRight:
            println("LandscapeRight")
            showLandscapeRight()
            
        default:
            println("Not a supported orientation")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    /*
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    if fromInterfaceOrientation.isPortrait {
    showLandscape()
    changePreview()
    previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
    }
    
    if fromInterfaceOrientation.isLandscape {
    showPortrait()
    changePreview()
    previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.Portrait
    }
    }*/
    
    
    
    // MARK
    // View handlers for either portrait or landscape orientation
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if toInterfaceOrientation == .Portrait {
            showPortrait()
            setPreview()
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        }
        else if toInterfaceOrientation == .LandscapeLeft {
            showLandscapeLeft()
            setPreview()
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        }
        else if toInterfaceOrientation == .LandscapeRight {
            showLandscapeRight()
            setPreview()
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        }
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
        if cameraViewHolder.frame.origin.x < otherViewHolder?.frame.origin.x {
            var cameraViewOrigin:CGPoint! = cameraViewHolder.frame.origin
            var otherViewOrigin:CGPoint! = otherViewHolder?.frame.origin
            cameraViewHolder.frame.origin = otherViewOrigin
            otherViewHolder?.frame.origin = cameraViewOrigin
        }
    }
    
    func showLandscapeLeft() {
        hidePortrait()
        cameraViewLandscape.hidden = false
        cameraViewHolder = cameraViewLandscape
        otherViewLandscape?.hidden = false
        otherViewHolder = otherViewLandscape
        // if view in landscape left then flip
        if cameraViewHolder.frame.origin.x > otherViewHolder?.frame.origin.x {
            var cameraViewOrigin:CGPoint! = cameraViewHolder.frame.origin
            var otherViewOrigin:CGPoint! = otherViewHolder?.frame.origin
            cameraViewHolder.frame.origin = otherViewOrigin
            otherViewHolder?.frame.origin = cameraViewOrigin
        }
    }
    
    // Show portrait views and hide landscape views
    func showPortrait() {
        hideLandscape()
        cameraViewPortrait.hidden = false
        cameraViewHolder = cameraViewPortrait
        otherViewPortrait?.hidden = false
        otherViewHolder = otherViewPortrait
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
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Front camera found")
                        self.setupCamera()
                    }
                }
            }
        }
    }
    
    // Setup to use front camera
    func setupCamera() {
        var err:NSError? = nil
        
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        // print error if one is present
        if err != nil {
            println("error : \(err?.localizedDescription)")
        }
        
        // setup AVCaptureMetadataOutput
        captureSession.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Add camera layer to view
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        setPreview()
        // Start video capture
        captureSession.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrFrameView.frame = CGRectZero
            println("No QR code is detected")
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
                println("QR Code: \(metadataObj.stringValue)")
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
    
    func setPreview() {
        if previewLayer != nil {
            previewLayer?.bounds = self.cameraViewHolder.layer.bounds
            previewLayer?.position = CGPointMake(CGRectGetMidX(cameraViewHolder.layer.bounds), CGRectGetMidY(cameraViewHolder.layer.bounds))
            self.cameraViewHolder?.layer.addSublayer(previewLayer)
        }
    }
    
   
}
