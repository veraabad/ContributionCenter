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
    
    // Landscape:
    // Info view
    @IBOutlet weak var infoViewL: UIView!
    // Camera view
    @IBOutlet weak var cameraViewL: UIView!
    
    // Label to show the name of the person in
    @IBOutlet weak var sisterLabel: UILabel!
    
    // Segment control to know what to do with QR code
    @IBOutlet weak var checkInSegmentControl: UISegmentedControl!
    var segmentPortraitConstraintsV: [AnyObject] = []
    var segmentPortraitConstraintsH: [AnyObject] = []
    var segmentLandscapeContraintsV: [AnyObject] = []
    var segmentLandscapeRightContraintsH: [AnyObject] = []
    var segmentLandscapeLeftConstraintsH: [AnyObject] = []
    var segmentHeightConstraint: [AnyObject] = []
    
    // Find out when were done with fetching boxes
    var fetchBoxes = dispatch_group_create()
    
    // If there is a parent view then save it here
    var parentVC:AVSideBarController!
    
    // Bool to indicate whether portait had been previous layout or not
    var portrait = false
    
    // Bool used to replace a sister
    var replaceBool = false
    
    // Holds array of sisters names
    var sisNames:[String]? = [String]()
    // Holds array of all boxes
    var boxesNumArray:[String]? = [String]()
    var boxesArray:[BoxesOut]? = [BoxesOut]()
    var boxesNoSis:[BoxesOut]? = [BoxesOut]()
    
    // Date formatter to display date info
    let dateFormatter = NSDateFormatter()
    
    // Holds sisters' information
    var currentSister:SisterInfo?
    var previousSister:SisterInfo?
    
    // Delay for camera
    var delaySec = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup date formatter
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        
        // Set top height
        topHeight = "64"

        // Setup views
        setPortraitViews(cameraViewP, otherView: infoViewP)
        setLandscapeViews(cameraViewL, otherView: infoViewL)
        
        // Create constraints for segment and label
        createConstraints()
        
        // Make sure nameLabel is cleared
        sisterLabel.text = ""
        
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
        // Get the boxes
        getBoxDict()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Find camera and start it up
        findCamera()
        previewLayerConnection = previewLayer?.connection
        setupQRFrameView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSisterInfo(sisterName:String) {
        currentSister = SisterInfo(sisterName: sisterName) {(success:Bool) -> Void in
            if success {
                self.displayInformation()
            }
            else {
                self.showAlert("Error", message: "Sisters' Name is not on the server")
            }
        }
    }
    
    // Find boxes that have not been assigned to any sisters
    func parseBox(box:BoxesOut) {
        if box.sisterAssigned != nil || box.sisterAssigned != "" {
            boxesNoSis? += [box]
        }
        boxesNoSis?.sort({$0.boxNumber < $1.boxNumber}) // Sort in ascending order
    }
    
    // Get all boxes number
    func getBoxDict() {
        ObjectIdDictionary.sharedInstance.updateBoxIdDict{(success:Bool, boxDict:[String:String]?) -> Void in
            if success {
                self.boxesNumArray = boxDict?.keys.array
                self.getBoxesInfo()
            }
            else {
                self.showAlert("Network Error", message: "Could not retrieve boxes information from server")
            }
        }
    }
    
    // Fill array of boxes
    func getBoxesInfo() {
        dispatch_group_enter(fetchBoxes)
        for boxNumber in boxesNumArray! {
            var boxInfo:BoxesOut?
            boxInfo = BoxesOut(boxNum: (boxNumber.toInt())!) {(success) -> Void in
                if success {
                    self.boxesArray! += [boxInfo!]
                    if self.boxesArray?.count == self.boxesNumArray?.count {
                        dispatch_group_leave(self.fetchBoxes)
                    }
                }
                else {
                    self.showAlert("Network Error", message: "Unable to retrieve info for box \(boxNumber)")
                }
                self.boxesArray?.sort({$0.boxNumber < $1.boxNumber})
            }
        }
    }
    
    func latestBoxInfo(block:(success:Bool) -> Void) {
        for var i = 0; i < boxesArray?.count; i++ {
            var box = boxesArray?[i]
            box!.fetchBoxInfo{(success) -> Void in
                if success{
                    if self.checkInSegmentControl.selectedSegmentIndex == 0 {
                        self.parseBox(box!)
                    }
                    println("Box: \(box?.boxNumber)")
                    if box?.boxNumber == self.boxesArray?.count {
                        block(success: true)
                    }
                }
                else {
                    block(success: false)
                    self.showAlert("Error", message: "Unable to retrieve info for box \(box!.boxNumber)")
                }
            }
        }
    }
    
    func checkInSister() {
        // Start getting boxes info
        dispatch_group_notify(fetchBoxes, dispatch_get_main_queue()) {
            self.latestBoxInfo{(success) -> Void in
                if success {
                    var box = self.boxesNoSis?[0]
                    println("Box number assigned: \(box!.boxNumber)")
                    self.currentSister?.boxAssigned = box?.boxNumber
                    box?.sisterAssigned = self.currentSister!.firstName! + " " + self.currentSister!.lastName!
                    box?.saveBoxInfo() // Save changes
                    
                    // Display confirmation to sister and save
                    self.sisterLabel.text = "\(box!.sisterAssigned!)\nBox Assigned is: #\(box!.boxNumber)"
                    self.currentSister?.saveSisterInfo()
                    self.clearCamera()
                }
            }
        }
    }
    
    func checkOutSister() {
        dispatch_group_notify(fetchBoxes, dispatch_get_main_queue()) {
            if let boxNum = self.currentSister?.boxAssigned {
                var box = self.boxesArray?[boxNum - 1]
                box?.sisterAssigned = ""
                // Save changes
                box?.saveBoxInfo()
                self.clearCamera() // Reset camera
            }
            
            // Display confirmation to sister
            self.sisterLabel.text = "You have returned box #\(self.currentSister!.boxAssigned!)\nThank you for your help"
            
            // Now clear out box and save
            self.currentSister?.boxAssigned = nil
            self.currentSister?.saveSisterInfo()
        }
    }
    
    func checkHours() {
        var friday:String = ""
        var saturday:String = ""
        var sunday:String = ""
        if let fridayD = currentSister?.fridayTime {
            friday = dateFormatter.stringFromDate(fridayD)
        }
        if let saturdayD = currentSister?.saturdayTime {
            saturday = dateFormatter.stringFromDate(saturdayD)
        }
        if let sundayD = currentSister?.sundayTime {
            sunday = dateFormatter.stringFromDate(sundayD)
        }
        
        // Display hours
        sisterLabel.text = "Friday: \(friday)\nSatuday: \(saturday)\nSunday: \(sunday)"
        clearCamera()
    }
    
    func replaceSister() {
        if !replaceBool {
            previousSister = currentSister
            sisterLabel.text = "Now scan the sister that will be the replacement"
            replaceBool = true
            clearCamera()
        }
        else {
            var boxNum = previousSister?.boxAssigned
            var box = boxesArray?[boxNum! - 1]
            box?.sisterAssigned = currentSister!.firstName! + " " + currentSister!.lastName!
            previousSister?.boxAssigned = nil
            currentSister?.boxAssigned = box?.boxNumber
            
            // Display confirmation
            sisterLabel.text = "Sister \(previousSister!.firstName!) \(previousSister!.lastName!) has been replaced by \(box!.sisterAssigned!) on box #\(box!.boxNumber)"
            
            // Save
            box?.saveBoxInfo()
            currentSister?.saveSisterInfo()
            previousSister?.saveSisterInfo()
            replaceBool = false
            clearCamera()
        }
    }
    
    func displayInformation() {
        // Choose what to do depending on segment control
        switch checkInSegmentControl.selectedSegmentIndex {
        case 0:
            checkInSister()
        case 1:
            checkOutSister()
        case 2:
            checkHours()
        case 3:
            replaceSister()
        default:
            println("Not part of segment choice")
        }
    }
    
    // MARK:
    // Constraint functions
    
    // Add constraints for landscape right
    override func showLandscapeRight() {
        super.showLandscapeRight()
        println("Segment Constraints being created")
        if portrait {
            self.view.removeConstraints(segmentPortraitConstraintsV)
            self.view.removeConstraints(segmentPortraitConstraintsH)
            portrait = false
        }
        else if landscapeLeft {
            self.view.removeConstraints(segmentLandscapeContraintsV)
            self.view.removeConstraints(segmentLandscapeLeftConstraintsH)
        }
        
        self.view.addConstraints(segmentLandscapeContraintsV)
        self.view.addConstraints(segmentLandscapeRightContraintsH)
    }
    
    // Add constraints for landscape left
    override func showLandscapeLeft() {
        super.showLandscapeLeft()
        
        if portrait {
            self.view.removeConstraints(segmentPortraitConstraintsV)
            self.view.removeConstraints(segmentPortraitConstraintsH)
            portrait = false
        }
        else if landscapeRight {
            self.view.removeConstraints(segmentLandscapeContraintsV)
            self.view.removeConstraints(segmentLandscapeRightContraintsH)
        }
        
        self.view.addConstraints(segmentLandscapeContraintsV)
        self.view.addConstraints(segmentLandscapeLeftConstraintsH)
    }
    
    // Add constraints for portrait
    override func showPortrait() {
        super.showPortrait()
        // Only do this for iPad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if landscapeRight {
                self.view.removeConstraints(segmentLandscapeContraintsV)
                self.view.removeConstraints(segmentLandscapeRightContraintsH)
            }
            else if landscapeLeft {
                self.view.removeConstraints(segmentLandscapeContraintsV)
                self.view.removeConstraints(segmentLandscapeLeftConstraintsH)
            }
            
            self.view.addConstraints(segmentPortraitConstraintsV)
            self.view.addConstraints(segmentPortraitConstraintsH)
            self.view.layoutSubviews()
            portrait = true
        }
    }
    
    func createConstraints() {
        sisterLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        checkInSegmentControl.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var viewsDict = ["labelView": sisterLabel, "segmentView": checkInSegmentControl, "cameraViewP": cameraViewPortrait, "cameraViewL": cameraViewLandscape]
        
        // Set constraints for portrait
        segmentPortraitConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[segmentView(==28)]-[labelView]-[cameraViewP]", options: .AlignAllCenterX, metrics: nil, views: viewsDict)
        
        segmentPortraitConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[segmentView(==labelView)]-|", options: .AlignAllLeading, metrics: nil, views: viewsDict)
        
        // Set constraints for landscape right
        segmentLandscapeRightContraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:[cameraViewL]-[segmentView(==labelView)]-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewsDict)
        
        // Set constraints for landscape left
        segmentLandscapeLeftConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[segmentView(==labelView)]-[cameraViewL]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewsDict)
        
        // Set vertical constraints for when in landscape mode
        segmentLandscapeContraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[segmentView(==28)]-[labelView]-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: viewsDict)
    }
    
    override func obtainRespon(qrResponse: String) {
        if qrResponse == "" {
            return
        }
        else {
            // Get sisters name from QR code
            getSisterInfo(qrResponse)
            captureSession.stopRunning()
            /*
            let delay = Double(delaySec) * Double(NSEC_PER_MSEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                println("Camera running again")
                
            }*/
            
        }
    }
    
    func clearCamera() {
        let delay = Double(delaySec) * Double(NSEC_PER_MSEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            println("Camera running again")
            self.qrFrameView.frame = CGRectZero // Removes the qrFrameView from sight once camera starts up again
            self.captureSession.startRunning()
        }
    }
    
    func showMenuAction() {
        println("Menu called")
        if parentVC != nil {
            parentVC.showMenu()
        }
    }
    
    // Handles when value changes in UISegmentControl
    @IBAction func checkInSegmentAction(sender: AnyObject) {
    }
    
    func showAlert(title:String, message:String) {
        var alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        //var alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.show()
        //self.presentViewController(alert, animated: true, completion: nil)
        clearCamera()
    }
}
