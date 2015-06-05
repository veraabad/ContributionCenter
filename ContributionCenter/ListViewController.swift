//
//  ListViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/18/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Table view that shows lists of sisters available to help
    @IBOutlet weak var listTableView: UITableView!
    
    // Holds array of sisters names if there are any
    var sisDictArray:[String]? = [String]()
    var sistersArray:[SisterInfo]? = [SisterInfo]()
    
    // Color
    var colorBack = UIColor(red: 10/255, green: 206/255, blue: 225/255, alpha: 1.0)
    var viewAlpha:CGFloat! = 0.2
    
    // If a parent VC is found store it here
    var parentVC:AVSideBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start tasks of obtaining sisters information
        obtainSisterDict()
        
        // Check for instance of parent and setup navController
        if let vc = self.navigationController?.parentViewController as? AVSideBarController {
            parentVC = vc
            // Have a clear background for UINavigationBar
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.translucent = true
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            
            // Navigation item on the right
            var rightItem = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .Plain, target: self, action: Selector("showMenuAction"))
            self.navigationItem.leftBarButtonItem = rightItem
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Bring out menu
    func showMenuAction() {
        if parentVC != nil {
            parentVC.showMenu()
        }
    }
    
    // Get the sisters object ID dictionary from the server
    func obtainSisterDict() {
        ObjectIdDictionary.sharedInstance.updateSisterIdDict{(success:Bool, sisDict: [String:String]?) -> Void in
            if success {
                if let keys = sisDict?.keys.array {
                    self.sisDictArray = keys
                    self.obtainSistersInfo()
                }
            }
            else {
                println("Sisters object ID dictionary was not found")
            }
        }
    }
    
    // Get the sisters information from the server
    func obtainSistersInfo() {
        for name in sisDictArray! {
            var sisInfo:SisterInfo?
            sisInfo = SisterInfo(sisterName: name) {(success) -> Void in
                if success {
                    self.sistersArray! += [sisInfo!]
                    if self.sistersArray?.count == self.sisDictArray?.count {
                        self.listTableView.reloadData()
                    }
                }
                else {
                    println("Sister has not been saved yet")
                }
            }
        }
    }
    
    func createBlur(dateBttn:UIButton) {
        var cornerRad:CGFloat = dateBttn.frame.height / 2
        // Blur for background of dates
        var blur:UIVisualEffectView! = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blur.frame = CGRectMake(0, 0, dateBttn.frame.height, dateBttn.frame.height)
        blur.userInteractionEnabled = false
        blur.layer.cornerRadius = cornerRad
        blur.clipsToBounds = true
        // Give it some color
        var backView:UIView! = UIView(frame: CGRectMake(0, 0, dateBttn.frame.height, dateBttn.frame.height))
        backView.backgroundColor = colorBack
        backView.alpha = viewAlpha
        backView.layer.cornerRadius = cornerRad
        backView.clipsToBounds = true
        backView.userInteractionEnabled = false
        
        // Add subviews
        dateBttn.addSubview(backView)
        dateBttn.addSubview(blur)
        dateBttn.sendSubviewToBack(backView)
        dateBttn.sendSubviewToBack(blur)
    }
    
    // MARK:
    // TableView functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sisDictArray?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = listTableView.dequeueReusableCellWithIdentifier("ListCell") as! ListTableViewCell
        cell.firstNameLabel.text = ""
        cell.lastNameLabel.text = ""
        if let sis = sistersArray?[indexPath.row] {
            cell.firstNameLabel.text = sis.firstName
            cell.lastNameLabel.text = sis.lastName
            cell.sisInfo = sis
            // Check for dates
            // If dates are available then show it on cell
            if sis.fridayTime != nil {
                createBlur(cell.fridayBttn)
            }
            if sis.saturdayTime != nil {
                createBlur(cell.saturdayBttn)
            }
            if sis.sundayTime != nil {
                createBlur(cell.sundayBttn)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Row selected is: \(indexPath.row)")
        let cell = listTableView.cellForRowAtIndexPath(indexPath) as! ListTableViewCell
        
        // Instantiante view controller
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("ListDetailVC") as! ListDetailViewController
        if let sisInfo = cell.sisInfo {
            vc.sisterInfo = sisInfo
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
