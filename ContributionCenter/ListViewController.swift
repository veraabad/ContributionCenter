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
            let leftItem = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .Plain, target: self, action: Selector("showMenuAction"))
            let rightItem = UIBarButtonItem(title: "QR", style: .Plain, target: self, action: Selector("loadPrintVC"))
            self.navigationItem.leftBarButtonItem = leftItem
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    func loadPrintVC() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PrintVC") as! PrintViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Reload data when view appears
        listTableView.reloadData()
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
                if let keys = sisDict?.keys {
                    self.sisDictArray = Array(keys)
                    self.obtainSistersInfo()
                }
            }
            else {
                print("Sisters object ID dictionary was not found")
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
                    // Reload after loading 10
                    if ((self.sistersArray?.count)! % 10) == 0 || self.sistersArray?.count == self.sisDictArray?.count {
                        self.sortSisterArray()
                        self.listTableView.reloadData()
                    }
                }
                else {
                    print("Sister has not been saved yet")
                }
            }
        }
    }
    
    // Sort the sistesr Array
    func sortSisterArray() {
        sistersArray?.sortInPlace({s1, s2 in
            if s1.lastName < s2.lastName {
                return true // If lastName is greater then place it on top
            }
            // If lastNames are the same then go by firstName
            else if s1.lastName == s2.lastName {
                if s1.firstName < s2.firstName {
                    return true
                }
                else {
                    return false
                }
            }
            // lastName in s2 is greater
            else {
                return false
            }
        })
    }
    
    func createBlur(dateBttn:UIButton) {
        let cornerRad:CGFloat = dateBttn.frame.height / 2
        // Blur for background of dates
        let blur:UIVisualEffectView! = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blur.frame = CGRectMake(0, 0, dateBttn.frame.height, dateBttn.frame.height)
        blur.userInteractionEnabled = false
        blur.layer.cornerRadius = cornerRad
        blur.clipsToBounds = true
        // Give it some color
        let backView:UIView! = UIView(frame: CGRectMake(0, 0, dateBttn.frame.height, dateBttn.frame.height))
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
    
    // Remove blur and color from button
    func removeBlur(dateBttn:UIButton) {
        var subViews = dateBttn.subviews
        if subViews.count >= 3 {
            let subView1 = subViews[0] as UIView
            let subView2 = subViews[1] as UIView
            subView1.removeFromSuperview()
            subView2.removeFromSuperview()
        }
    }
    
    // MARK:
    // TableView functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sistersArray?.count)!
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
            if (sis.fridayTime != nil) && (cell.bttnBackBool?["Friday"] != true) {
                createBlur(cell.fridayBttn)
                cell.bttnBackBool?["Friday"] = true
            }
            else if (cell.bttnBackBool?["Friday"] == true) && (sis.fridayTime == nil) {
                removeBlur(cell.fridayBttn)
                cell.bttnBackBool?["Friday"] = false
            }
            
            if (sis.saturdayTime != nil) && (cell.bttnBackBool?["Saturday"] != true) {
                createBlur(cell.saturdayBttn)
                cell.bttnBackBool?["Saturday"] = true
            }
            else if (cell.bttnBackBool?["Saturday"] == true) && (sis.saturdayTime == nil){
                removeBlur(cell.saturdayBttn)
                cell.bttnBackBool?["Saturday"] = false
            }
            
            if (sis.sundayTime != nil) && (cell.bttnBackBool?["Sunday"] != true) {
                createBlur(cell.sundayBttn)
                cell.bttnBackBool?["Sunday"] = true
            }
            else if (cell.bttnBackBool?["Sunday"] == true) && (sis.sundayTime == nil) {
                removeBlur(cell.sundayBttn)
                cell.bttnBackBool?["Sunday"] = false
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Row selected is: \(indexPath.row)")
        let cell = listTableView.cellForRowAtIndexPath(indexPath) as! ListTableViewCell
        
        // Instantiante view controller
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ListDetailVC") as! ListDetailViewController
        if let sisInfo = cell.sisInfo {
            vc.sisterInfo = sisInfo
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
