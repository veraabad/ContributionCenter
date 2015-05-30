//
//  LogInViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 4/24/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//
import UIKit
import LocalAuthentication


class LogInViewController: UIViewController {
    // UIButton
    @IBOutlet weak var procederBttn: UIButton!
    
    // Blur for background of button
    var blur:UIVisualEffectView!
    
    // Device interface
    var deviceInterface:UIUserInterfaceIdiom!
    
    var objectid:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load one user
        /*
        var userInfo = PFObject(className: "SisterInfo")
        userInfo["firstName"] = "Cristina"
        userInfo["lastName"] = "Vera"
        userInfo["userEmail"] = "gutierrezdiana.cv@gmail.com"
        userInfo.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
            if success {
                println("User info saved")
                println("Object ID: \(userInfo.objectId)")
            }
            else {
                println("Error: \(error?.userInfo)")
            }
        }*/
        
        // Find out which device were on
        deviceInterface = UIDevice.currentDevice().userInterfaceIdiom
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
                        self.showVC("AuthenticatedVC")
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        println("Unable to Authenticate")
                    })
                }
            })
        }
    }
    
    func showVC(stringID: String) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyBoard.instantiateViewControllerWithIdentifier(stringID) as! UIViewController
        self.showViewController(viewC, sender: self)
    }
    
    func test(sisObject: SisterInfo?) {
        println("Name: \(sisObject?.firstName)")
    }
    
    // Action for when the "Proceder" button has been pressed
    @IBAction func procedeAction(sender: AnyObject) {
        // Try saving a sisterInfo
        
        // If iPhone then user fingerprint to login
        if deviceInterface == .Phone {
            requestFingerprintAuthentication()
        }
        else if deviceInterface == .Pad {
            showVC("AuthenticationVC") // If iPad then go to QRAuthentication
        }
    }

}
