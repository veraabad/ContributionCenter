//
//  MenuViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/7/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    // Table view for menu items
    @IBOutlet weak var menuTableView: UITableView!
    // To hold instance of parent view controller
    var parentVC: AVSideBarController!
    
    // Labels for the menu items
    var menuItems:[String] = ["QR Check In", "Boxes Out", "Sign In iPad", "List"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if let parent = self.parentViewController as! AVSideBarController! {
            println("Has parent")
            // Hold instance of parent view controller
            parentVC = parent
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Hide menu
    @IBAction func closeMenuAction(sender: AnyObject) {
        parentVC.hideMenu()
    }
    @IBAction func logoutAction(sender: AnyObject) {
    }
    
    // MARK
    // Tableview functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuTableViewCell
        cell.menuItemLabel.text = menuItems[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Bring up view depending on which cell chosen
        let cell = menuTableView.cellForRowAtIndexPath(indexPath) as! MenuTableViewCell
        println("Title: \(cell.menuItemLabel.text)")
        let menuItem:String! = cell.menuItemLabel.text
        switch menuItem {
        case "Sign In iPad":
            removeSelectionHighlight(indexPath)
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("QRNavController") as? UINavigationController {
                parentVC.moveMenu(vc)
            }
            
        case "QR Check In":
            removeSelectionHighlight(indexPath)
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CheckInNavController") as? UINavigationController {
                parentVC.moveMenu(vc)
            }
        case "List":
            removeSelectionHighlight(indexPath)
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ListNavController") as? UINavigationController {
                parentVC.moveMenu(vc)
            }
        case "Hi":
            println("")
        default:
            println("Not a viable cell item")
        }
    }
    
    // Remove the highlight shown when a cell is selected
    func removeSelectionHighlight(indexPath: NSIndexPath) {
        menuTableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
