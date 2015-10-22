//
//  EditListDetailViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/18/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

protocol EditListDetailViewControllerDelegate {
    func saveSisterInfo(controller:EditListDetailViewController, sisInfo:SisterInfo?)
}

class EditListDetailViewController: UIViewController, UITextFieldDelegate {
    // Text fields to edit sisters' info
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var congregationTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cellNumberTextField: UITextField!
    @IBOutlet weak var homeNumberTextField: UITextField!
    // Will be using UIDatePicker for these textFields
    @IBOutlet weak var fridayDateTextField: UITextField!
    @IBOutlet weak var saturdayDateTextField: UITextField!
    @IBOutlet weak var sundayDateTextField: UITextField!
    
    // Color
    var colorTfFilled = UIColor(red: 44/255, green: 64/255, blue: 116/255, alpha: 1.0)
    var colorTfNotFilled = UIColor(red: 10/255, green: 206/255, blue: 225/255, alpha: 1.0)
    var viewAlpha:CGFloat! = 0.2
    var cornerRad:CGFloat! = 3
    
    // Bottom constraint for dateUITextField
    @IBOutlet weak var dateTextFieldBottomConstraint: NSLayoutConstraint!
    // Top constraint
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    // Hold constant
    var constantHolderBottom:CGFloat!
    var constantHolderTop:CGFloat!
    // Know if we changed constraint
    var moved:Bool! = false
    
    // UIDatePicker for choosing time
    var datePickerView:UIDatePicker!
    
    // Holds active textField
    var textFieldHolder:UITextField?
    
    // Delegate property
    var delegate:EditListDetailViewControllerDelegate! = nil
    
    // Right bar button item that says "Done"
    var rightItem:UIBarButtonItem!
    
    // Date formatter for sisters date info
    let timeFormatter = NSDateFormatter()
    var fridayD:NSDate!
    var saturdayD:NSDate!
    var sundayD:NSDate!
    
    // Holds sister information
    var sisInfo:SisterInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup date formatter
        timeFormatter.dateStyle = .NoStyle
        timeFormatter.timeStyle = .ShortStyle
        
        // Set days
        setDays()
        
        // Clear any values in the textfields
        clearTextFields()
        // If a navBar is present then add left and right bar items
        if self.navigationController != nil {
            let leftItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancelAction"))
            rightItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: Selector("doneAction"))
            rightItem.enabled = false
            self.navigationItem.leftBarButtonItem = leftItem
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // If we have the sister information then procede
        if sisInfo != nil {
            parseSisterInfo()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // If view is touched then dismiss the textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if textFieldHolder != nil {
            if (textFieldHolder?.isFirstResponder())! {
                if textFieldHolder?.tag == 7 | 8 | 9 {
                    donePicking()
                }
                else {
                    // Dismiss any textFields
                    view.endEditing(true)
                }
                // Check for changes
                checkIfChangesMade()
            }
        }
    }
    
    // Saves any changes made to sisters' info
    func doneAction() {
        sisInfo?.saveSisterInfo()
        delegate.saveSisterInfo(self, sisInfo: sisInfo)
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    // checks if there have been any changes made to the sisters' info
    func checkIfChangesMade() {
        if (sisInfo?.dirty)! {
            rightItem.enabled = true
        }
        else {
            rightItem.enabled = false
        }
    }
    
    // Remove view
    // Any changes will be discarded
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func parseSisterInfo() {
        if let firstName = sisInfo?.firstName {
            if firstName != "" {
                firstNameTextField.text = firstName
                addBackground(firstNameTextField, filled: true)
            }
            else {
                addBackground(firstNameTextField, filled: false)
            }
        }
        else {
            addBackground(firstNameTextField, filled: false)
        }
        
        if let lastName = sisInfo?.lastName {
            if lastName != "" {
                lastNameTextField.text = lastName
                addBackground(lastNameTextField, filled: true)
            }
            else {
                addBackground(lastNameTextField, filled: false)
            }
        }
        else {
            addBackground(lastNameTextField, filled: false)
        }
        
        if let congregation = sisInfo?.congregation {
            if congregation != "" {
                congregationTextField.text = congregation
                addBackground(congregationTextField, filled: true)
            }
            else {
                addBackground(congregationTextField, filled: false)
            }
        }
        else {
            addBackground(congregationTextField, filled: false)
        }
        
        if let email = sisInfo?.email {
            if email != "" {
                emailTextField.text = email
                addBackground(emailTextField, filled: true)
            }
            else {
                addBackground(emailTextField, filled: false)
            }
        }
        else {
            addBackground(emailTextField, filled: false)
        }
        
        if let cellNumber = sisInfo?.phoneNumber {
            cellNumberTextField.text = String(cellNumber)
            addBackground(cellNumberTextField, filled: true)
        }
        else {
            addBackground(cellNumberTextField, filled: false)
        }
        
        if let houseNumber = sisInfo?.housePhone {
            homeNumberTextField.text = String(houseNumber)
            addBackground(homeNumberTextField, filled: true)
        }
        else {
            addBackground(homeNumberTextField, filled: false)
        }
        
        // Dates helping
        if let friday = sisInfo?.fridayTime {
            fridayDateTextField.text = timeFormatter.stringFromDate(friday)
            addBackground(fridayDateTextField, filled: true)
        }
        else {
            addBackground(fridayDateTextField, filled: false)
        }
        
        if let saturday = sisInfo?.saturdayTime {
            saturdayDateTextField.text = timeFormatter.stringFromDate(saturday)
            addBackground(saturdayDateTextField, filled: true)
        }
        else {
            addBackground(saturdayDateTextField, filled: false)
        }
        if let sunday = sisInfo?.sundayTime {
            sundayDateTextField.text = timeFormatter.stringFromDate(sunday)
            addBackground(sundayDateTextField, filled: true)
        }
        else {
            addBackground(sundayDateTextField, filled: false)
        }
    }
    
    func clearTextFields() {
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        congregationTextField.text = ""
        emailTextField.text = ""
        cellNumberTextField.text = ""
        homeNumberTextField.text = ""
        fridayDateTextField.text = ""
        saturdayDateTextField.text = ""
        sundayDateTextField.text = ""
    }
    
    // Add a background to differentiate what has been filled in and what hasn't
    func addBackground(textField: UITextField, filled:Bool) {
        // Make blur
        let blur:UIVisualEffectView! = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blur.frame = CGRectMake(0, 0, textField.frame.width, textField.frame.height)
        blur.alpha = viewAlpha
        blur.userInteractionEnabled = false
        blur.layer.cornerRadius = cornerRad
        blur.clipsToBounds = true
        
        // Make colored background
        let backView:UIView! = UIView(frame: CGRectMake(0, 0, textField.frame.width, textField.frame.height))
        backView.alpha = viewAlpha
        backView.layer.cornerRadius = cornerRad
        backView.clipsToBounds = true
        backView.userInteractionEnabled = false
        if filled {
            backView.backgroundColor = colorTfFilled
        }
        else {
            backView.backgroundColor = colorTfNotFilled
        }
        
        // Add to textfield
        textField.addSubview(backView)
        textField.addSubview(blur)
        textField.sendSubviewToBack(backView)
        textField.sendSubviewToBack(blur)
    }
    
    func setDays() {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        // Friday
        let friday = NSDateComponents()
        friday.day = 12
        friday.month = 6
        friday.year = 2015
        fridayD = calendar?.dateFromComponents(friday)
        // Saturday
        let saturday = NSDateComponents()
        saturday.day = 13
        saturday.month = 6
        saturday.year = 2015
        saturdayD = calendar?.dateFromComponents(saturday)
        // Sunday
        let sunday = NSDateComponents()
        sunday.day = 14
        sunday.month = 6
        sunday.year = 2015
        sundayD = calendar?.dateFromComponents(sunday)
    }
    
    // MARK:
    // TextField functions
    
    // Bring up UIDatePicker when selecting one of these textFields
    @IBAction func dateFieldAction(sender: UITextField) {
        // Create Date Picker
        datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Time
        // Set date depending on day
        switch sender.tag {
        case 7:
            if sender.text != "" {
                datePickerView.setDate((sisInfo?.fridayTime)!, animated: false)
            }
            else {
                datePickerView.setDate(fridayD, animated: false)
            }
        case 8:
            if sender.text != "" {
                datePickerView.setDate((sisInfo?.saturdayTime)!, animated: false)
            }
            else {
                datePickerView.setDate(saturdayD, animated: false)
            }
        case 9:
            if sender.text != "" {
                datePickerView.setDate((sisInfo?.sundayTime)!, animated: false)
            }
            else {
                datePickerView.setDate(sundayD, animated: false)
            }
        default:
            print("Not a convention day")
        }
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleDatePickerView:"), forControlEvents: UIControlEvents.ValueChanged)
        createDateToolbar(sender)
    }
    
    // Once done chosing time then save it to the sisInfo
    func donePicking() {
        textFieldHolder?.textColor = UIColor.whiteColor()
        switch (textFieldHolder?.tag)! {
        case 5:
            sisInfo?.phoneNumber = Int((textFieldHolder?.text)!)
        case 6:
            sisInfo?.housePhone = Int((textFieldHolder?.text)!)
        case 7:
            textFieldHolder?.text = timeFormatter.stringFromDate(datePickerView.date)
            sisInfo?.fridayTime = datePickerView.date
        case 8:
            textFieldHolder?.text = timeFormatter.stringFromDate(datePickerView.date)
            sisInfo?.saturdayTime = datePickerView.date
        case 9:
            textFieldHolder?.text = timeFormatter.stringFromDate(datePickerView.date)
            sisInfo?.sundayTime = datePickerView.date
        default:
            print("Not a valid textField")
        }
        textFieldHolder?.resignFirstResponder()
        checkIfChangesMade()
    }
    
    func removeValue() {
        textFieldHolder?.textColor = UIColor.whiteColor()
        switch (textFieldHolder?.tag)! {
        case 5:
            sisInfo?.phoneNumber = nil
        case 6:
            sisInfo?.housePhone = nil
        case 7:
            sisInfo?.fridayTime = nil
        case 8:
            sisInfo?.saturdayTime = nil
        case 9:
            sisInfo?.sundayTime = nil
        default:
            print("Not a valid textField")
        }
        textFieldHolder?.text = ""
        textFieldHolder?.resignFirstResponder()
        checkIfChangesMade()
    }
    
    func cancelPicking() {
        // Remove any time info on the textfields and replace it with original
        parseSisterInfo()
        view.endEditing(true)
    }
    
    // Create a uitoolbar to add on top of uidatepicker
    func createDateToolbar(sender:UITextField) {
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, 0, 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: Selector("donePicking"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancelPicking"))
        let removeButton = UIBarButtonItem(title: "Remove", style: .Plain, target: self, action: Selector("removeValue"))
        var items:[UIBarButtonItem]! = [UIBarButtonItem]()
        items.append(cancelButton)
        items.append(flexibleSpace)
        items.append(removeButton)
        items.append(flexibleSpace)
        items.append(doneButton)
        toolBar.items = items
        toolBar.sizeToFit()
        print("Called")
        sender.inputAccessoryView = toolBar
    }
    
    // Display date info in textField
    func handleDatePickerView(sender: UIDatePicker) {
        textFieldHolder?.textColor = UIColor.whiteColor()
        switch (textFieldHolder?.tag)! {
        case 7:
            textFieldHolder?.text = timeFormatter.stringFromDate(sender.date)
        case 8:
            textFieldHolder?.text = timeFormatter.stringFromDate(sender.date)
        case 9:
            textFieldHolder?.text = timeFormatter.stringFromDate(sender.date)
        default:
            print("Not a valid textField")
        }
    }
    
    // Add notification for when keyboard is about to show
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // Grab reference to text field
        textFieldHolder = textField
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardDidShowNotification, object: nil)
        // Add toolbar to these textFields as well
        switch textField.tag {
        case 5,6:
            createDateToolbar(textField)
        default:
            print("It's another textField")
        }
        
        return true
    }
    
    // If keyboard will cover a textField then move the views
    func keyboardDidShow(notification:NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardFrame:CGRect! = (info.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue).CGRectValue()
        
        if (self.view.frame.height - keyboardFrame.size.height) < ((textFieldHolder?.frame.height)! + (textFieldHolder?.frame.origin.y)!) {
            print("keyboard did show")
            moved = true
            
            UIView.animateWithDuration(0.1, animations: {() -> Void in
                self.constantHolderBottom = self.dateTextFieldBottomConstraint.constant
                self.dateTextFieldBottomConstraint.constant = keyboardFrame.size.height
                self.topLayoutConstraint.priority = 250
                self.dateTextFieldBottomConstraint.priority = 750
            })
        }
    }
    
    // Add notification for when keyboard is about to hide
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name: UIKeyboardDidHideNotification, object: nil)
        return true
    }
    
    // If we did move view for keyboard then place everything back
    func keyboardDidHide(notification:NSNotification) {
        if moved! {
            let info:NSDictionary = notification.userInfo!
            var keyboardFrame:CGRect! = (info.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue).CGRectValue()
            
            UIView.animateWithDuration(0.1, animations: {() -> Void in
                self.dateTextFieldBottomConstraint.constant = self.constantHolderBottom
                self.topLayoutConstraint.priority = 750
                self.dateTextFieldBottomConstraint.priority = 250
            })
            moved = false
        }
        
    }
    
    // Dismiss keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        switch textField.tag {
        case 1:
            sisInfo?.firstName = textField.text
        case 2:
            sisInfo?.lastName = textField.text
        case 3:
            sisInfo?.congregation = textField.text
        case 4:
            sisInfo?.email = textField.text
        default:
            print("Not a valid textField")
        }
        
        // If changes have been made then enable the Done button
        checkIfChangesMade()
        
        return true
    }

}
