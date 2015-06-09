//
//  ListDetailViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/18/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class ListDetailViewController: UIViewController, EditListDetailViewControllerDelegate {
    // Labels to display detailed information on sister
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var congregationLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cellNumberLabel: UILabel!
    @IBOutlet weak var housePhoneNumberLabel: UILabel!
    @IBOutlet weak var fridayTimeLabel: UILabel!
    @IBOutlet weak var saturdayTimeLabel: UILabel!
    @IBOutlet weak var sundayTimeLabel: UILabel!
    
    // Holds the sister info
    var sisterInfo:SisterInfo?
    
    // Date formatter to display date info
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup date formatter
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle

        // Clear out any values in the UILabels
        clearLabels()
        
        // If sisters Info has been provided then procede
        if sisterInfo != nil {
            getRecentSisterInfo()
        }
        
        if self.navigationController != nil {
            var rightItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: Selector("editSisterInfo"))
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Bring up view controller to edit sisters info
    func editSisterInfo() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EditListVC") as! EditListDetailViewController
        vc.delegate = self
        vc.sisInfo = sisterInfo
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // Save sisterInfo and parse it to display it
    func saveSisterInfo(controller: EditListDetailViewController, sisInfo: SisterInfo?) {
        sisterInfo = sisInfo
        clearLabels()
        parseSisterInfo()
    }
    
    // Get all info that is available
    func parseSisterInfo() {
        // Get full name
        if let firstName = sisterInfo?.firstName {
            if let lastName = sisterInfo?.lastName{
                fullNameLabel.text = firstName + " " + lastName
            }
        }
        // Get congregation name
        if let congregation = sisterInfo?.congregation {
            congregationLabel.text = congregation
        }
        // Get email 
        if let email = sisterInfo?.email {
            emailLabel.text = email
        }
        // Get cell phone number
        if let cellNum = sisterInfo?.phoneNumber {
            cellNumberLabel.text = String(cellNum)
        }
        // Get home phone number
        if let homeNum = sisterInfo?.housePhone {
            housePhoneNumberLabel.text = String(homeNum)
        }
        // Get time helping out on friday
        if let fridayTime = sisterInfo?.fridayTime {
            fridayTimeLabel.text = dateFormatter.stringFromDate(fridayTime)
        }
        // Get time helping out on saturday
        if let saturdayTime = sisterInfo?.saturdayTime {
            saturdayTimeLabel.text = dateFormatter.stringFromDate(saturdayTime)
        }
        // Get time helping out on sunday
        if let sundayTime = sisterInfo?.sundayTime {
            sundayTimeLabel.text = dateFormatter.stringFromDate(sundayTime)
        }
    }
    
    // Request most recent information for this particular sister
    func getRecentSisterInfo() {
        sisterInfo?.fetchSisterInfo{(success:Bool) -> Void in
            // If we can get recent info then parse it
            if success {
                self.parseSisterInfo()
            }
            else {
                println("Was unable to fetch most recent sister info")
            }
        }
    }
    
    func clearLabels() {
        fullNameLabel.text = ""
        congregationLabel.text = ""
        emailLabel.text = ""
        cellNumberLabel.text = ""
        housePhoneNumberLabel.text = ""
        fridayTimeLabel.text = ""
        saturdayTimeLabel.text = ""
        sundayTimeLabel.text = ""
    }

}
