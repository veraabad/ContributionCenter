//
//  BoxesListViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 6/6/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class BoxesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Tableview that displays boxes
    @IBOutlet weak var boxesTableView: UITableView!
    // UISegmented Control to display certain boxes
    @IBOutlet weak var boxesSegment: UISegmentedControl!
    
    // Holds array of boxes 
    var boxesDictArray:[String]? = [String]()
    var boxesArray:[BoxesOut]? = [BoxesOut]()
    var boxesArrayHolder:[BoxesOut]? = [BoxesOut]()
    
    // If a parent VC is found store it here
    var parentVC:AVSideBarController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start task of obtaining box information
        obtainBoxesDict()

        // Check for instance of the paretn and setup navController
        if let vc = self.navigationController?.parentViewController as? AVSideBarController {
            parentVC = vc
            // Have a clear background for UINavigationBar
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.translucent = true
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            
            // Navigation item on the right
            let rightItem = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .Plain, target: self, action: Selector("showMenuAction"))
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
    
    // Handles any value changes in the UISegmentedControl
    @IBAction func boxesSegmentedAction(sender: AnyObject) {
        // Make a call to this function in order to check data
        boxSelection()
    }
    
    // MARK:
    // Box functions
    
    // Get the boxes object ID dictionary from the server
    func obtainBoxesDict() {
        ObjectIdDictionary.sharedInstance.updateBoxIdDict{(success:Bool, boxDict: [String:String]?) -> Void in
            if success {
                if let keys = boxDict?.keys {
                    self.boxesDictArray = Array(keys)
                    self.obtainBoxInfo()
                }
            }
            else {
                print("Boxes object ID dictionary could not be retrieved")
            }
        }
    }
    
    // Get the boxes information from the server
    func obtainBoxInfo() {
        for boxNumber in boxesDictArray! {
            var boxInfo:BoxesOut?
            boxInfo = BoxesOut(boxNum: (Int(boxNumber))!) {(success) -> Void in
                if success {
                    self.boxesArray! += [boxInfo!]
                    if self.boxesArray?.count == 10 {
                        self.boxSelection() // Load 15 and then load rest
                    }
                    else if self.boxesArray?.count == self.boxesDictArray?.count {
                        self.boxSelection() // Run through selective choosing
                    }
                }
                else {
                    print("Box has not been saved yet")
                }
            }
        }
    }
    
    // Select boxes
    func boxSelection() {
        // Clear out array
        boxesArrayHolder = []
        for box in boxesArray! {
            switch boxesSegment.selectedSegmentIndex {
            case 0:
                if box.sisterAssigned != nil && box.sisterAssigned != ""  {
                    boxesArrayHolder! += [box] // Only show the boxes that have been assigned
                }
            case 1:
                if box.sisterAssigned == "" || box.sisterAssigned == nil {
                    boxesArrayHolder! += [box] // Only show the boxes not assigned
                }
            case 2:
                boxesArrayHolder! += [box] // Show all boxes
            default:
                print("Not defined selection")
            }
        }
        // Sort array
        boxesArrayHolder?.sortInPlace({$0.boxNumber < $1.boxNumber})
        boxesTableView.reloadData()
    }
    
    // MARK:
    // TableView functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (boxesArrayHolder?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = boxesTableView.dequeueReusableCellWithIdentifier("BoxesCell") as! BoxesTableViewCell
        cell.boxNumberLabel.text = ""
        cell.sistersNameLabel.text = ""
        if let box = boxesArrayHolder?[indexPath.row] {
            cell.boxNumberLabel.text = String(box.boxNumber)
            cell.sistersNameLabel.text = box.sisterAssigned
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Row selected \(indexPath.row)")
    }
}
