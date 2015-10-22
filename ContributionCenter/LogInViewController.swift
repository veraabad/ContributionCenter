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
    var backView:UIView!
    
    // Color
    var colorBack = UIColor(red: 10/255, green: 206/255, blue: 225/255, alpha: 1.0)
    // Corner radius
    var cornerRad:CGFloat! = 2
    
    // Device interface
    var deviceInterface:UIUserInterfaceIdiom!
    
    var objectid:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Find out which device were on
        deviceInterface = UIDevice.currentDevice().userInterfaceIdiom
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Add blurred background to UIButton
        backView = UIView(frame: CGRectMake(0, 0, procederBttn.frame.width, procederBttn.frame.height))
        backView.backgroundColor = colorBack
        backView.alpha = 0.2
        backView.layer.cornerRadius = cornerRad
        backView.clipsToBounds = true
        backView.userInteractionEnabled = false
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blur.frame = CGRectMake(0, 0, procederBttn.frame.width, procederBttn.frame.height)
        blur.layer.cornerRadius = cornerRad
        blur.clipsToBounds = true
        blur.userInteractionEnabled = false
        procederBttn.addSubview(backView)
        procederBttn.addSubview(blur)
        procederBttn.sendSubviewToBack(backView)
        procederBttn.sendSubviewToBack(blur)
    }

    // Update frame of blur with rotation
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        blur.frame = CGRectMake(0, 0, procederBttn.frame.width, procederBttn.frame.height)
        backView.frame = CGRectMake(0, 0, procederBttn.frame.width, procederBttn.frame.height)
    }
    
    func requestFingerprintAuthentication() {
        let context = LAContext()
        var authError: NSError?
        let authenticationReason = "Porfavor registrese con su huella"
        
        // Check if device has fingerprint reader
        // If so then lets authenticate
        do {
            let err = NSErrorPointer()
            try context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:err)
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: authenticationReason, reply: {
                (success: Bool, error: NSError?) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Woohoo")
                        self.showVC("AuthenticatedVC")
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Unable to Authenticate: \(err)")
                        self.showVC("AuthenticatedVC")
                    })
                }
            })
        } catch let error as NSError {
            authError = error
            print("We're in the simulator")
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SideBarController") as! AVSideBarController
            self.showViewController(vc, sender: self)
        }
    }
    
    func showVC(stringID: String) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyBoard.instantiateViewControllerWithIdentifier(stringID) as UIViewController
        self.showViewController(viewC, sender: self)
    }
    
    // Action for when the "Proceder" button has been pressed
    @IBAction func procedeAction(sender: AnyObject) {
        // If iPhone then user fingerprint to login
        if deviceInterface == .Phone {
            requestFingerprintAuthentication()
        }
        else if deviceInterface == .Pad {
            showVC("AuthenticationVC") // If iPad then go to QRAuthentication
            /*let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SideBarController") as! AVSideBarController
            self.showViewController(vc, sender: self)*/
        }
    }

}
