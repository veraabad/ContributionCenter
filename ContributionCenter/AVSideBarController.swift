//
//  AVSideBarController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/8/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

// Implementation for a menu side bar
// This is the side bar container view controller

import UIKit

enum TRANSITION {
    case RIGHT, LEFT, NONE
}


class AVSideBarController: UIViewController {
    
    // View controller for sidebar Menu
    var sideMenuVC: MenuViewController!
    // View controller that is called by the sidebar Menu
    var currentVC: UIViewController!
    
    // UINavigationController for child view
    var childNav:UINavigationController!
    
    // Previous view controller
    var previousVC:UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup side menu view controller
        sideMenuVC = self.storyboard?.instantiateViewControllerWithIdentifier("MenuVC") as! MenuViewController
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CheckInNavController") as! UINavigationController
        addVC(vc)
        showCurrentVC()
    }
    
    // Bring up menu
    override func viewWillAppear(animated: Bool) {
        /*
        self.addChildViewController(sideMenuVC)
        sideMenuVC.view.frame = self.view.frame
        self.view.addSubview(sideMenuVC.view)
        sideMenuVC.didMoveToParentViewController(self) */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Add a view controller to currentVC property
    func addVC(vc: UIViewController) {
        currentVC = vc
    }
    
    // Add previous view controller if available
    func shiftCurrentVC() {
        if currentVC != nil {
            previousVC = currentVC
        }
    }
    
    // Show current view controller without animation
    func showCurrentVC() {
        currentVC.view.frame = self.view.frame
        
        self.addChildViewController(currentVC)
        self.view.addSubview(currentVC.view)
        currentVC.didMoveToParentViewController(self)
    }
    
    func removeVC(vc: UIViewController) {
        vc.willMoveToParentViewController(nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
    
    func showMenu() {
        // show menu
        showViewControllerFromSide(sideMenuVC, inContainer: self.view, bounds: self.view.bounds, side: .LEFT)
    }
    
    // Hide side menu
    func hideMenu() {
        dismissViewControllerToSide(sideMenuVC, side: .LEFT, nil)
    }
    
    func moveMenu(newVC: UIViewController) {
        if newVC.restorationIdentifier != currentVC.restorationIdentifier {
            println("Not Same")
            // Move previous current view controller
            shiftCurrentVC()
            // Add newVC to currentVC
            addVC(newVC)
            
            // Animate appearance
            showViewControllerFromSide(newVC, inContainer: self.view, bounds: self.view.bounds, side: .RIGHT)
        }
        else if newVC.restorationIdentifier == currentVC.restorationIdentifier {
            println("Same")
            hideMenu()
        }
    }
    
    
    //Show view controller from the side.
    func showViewControllerFromSide(viewController: UIViewController,
        inContainer containerView: UIView, bounds: CGRect, side: TRANSITION) {
            // New view
            let toView = viewController.view;
            
            // Setup bounds for new view controller view
            toView.translatesAutoresizingMaskIntoConstraints()
            toView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
            var frame = bounds
            frame.origin.y = containerView.frame.height - bounds.height
            switch side {
            case .LEFT:
                frame.origin.x = -containerView.frame.size.width // From left
            case .RIGHT:
                frame.origin.x = containerView.frame.size.width // From right
            default:break
            }
            toView.frame = frame
            
            self.addChildViewController(viewController)
            containerView.addSubview(toView)
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
                initialSpringVelocity: 1.0, options: nil, animations: { () -> Void in
                    switch side {
                    case .LEFT, .RIGHT:
                        frame.origin.x = 0
                    default:break
                    }
                    toView.frame = frame
                }) { (fin: Bool) -> Void in
                    viewController.didMoveToParentViewController(self)
            }
    }
    
    // Dismiss the view controller through moving it back to given side
    func dismissViewControllerToSide(viewController: UIViewController, side: TRANSITION, _ callback:(()->())?) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0, options: nil, animations: { () -> Void in
                // Move back to bottom
                switch side {
                case .LEFT:
                    viewController.view.frame.origin.x = -self.view.frame.size.width
                case .RIGHT:
                    viewController.view.frame.origin.x = self.view.frame.size.width
                default:break
                }
                
            }) { (fin: Bool) -> Void in
                viewController.willMoveToParentViewController(nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
                callback?()
        }
    }
    
}
