//
//  LogInViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 4/24/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//
import UIKit
import Parse
import LocalAuthentication


class LogInViewController: UIViewController {
    // UIButton
    @IBOutlet weak var procederBttn: UIButton!
    
    // Blur for background of button
    var blur:UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Testing of Parse service
        /*let testObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            println("Object has been saved.")
        } */
        
        // if iPhone then only allow view in portrait
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            let devOrientation = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(devOrientation, forKey: "orientation")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Add blurred background to UIButton
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blur.frame = CGRectMake(0, 0, procederBttn.frame.width, procederBttn.frame.height)
        blur.userInteractionEnabled = false
        procederBttn.addSubview(blur)
        procederBttn.sendSubviewToBack(blur)
        
        
    }
    
    // Only autorotate this screen if on ipad
    override func shouldAutorotate() -> Bool {
        var rotateBool:Bool!
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            rotateBool = false
        }
        else {
            rotateBool = true
        }
        return rotateBool
    }
    
    // Update frame of blur with rotation
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        blur.frame = CGRectMake(0, 0, procederBttn.frame.width, procederBttn.frame.height)
    }
    
    func requestFingerprintAuthentication() {
        let context = LAContext()
        var authError: NSError?
        let authenticationReason = "Porfavor registrese con su huella"
        
        // Check if device has fingerprint reader
        // If so then lets authenticate
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: authenticationReason, reply: {
                (success: Bool, error: NSError?) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        println("Woohoo")
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        println("Unable to Authenticate")
                    })
                }
            })
        }
    }
    
    // Action for when the "Proceder" button has been pressed
    @IBAction func procedeAction(sender: AnyObject) {
        requestFingerprintAuthentication()
        println("Hi")
    }

}
