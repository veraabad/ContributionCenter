//
//  LogInViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 4/24/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//
import UIKit
import LocalAuthentication
import SwiftCSV

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
        else {
            println("We're in the simulator")
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SideBarController") as! AVSideBarController
            self.showViewController(vc, sender: self)
        }
    }
    
    func showVC(stringID: String) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyBoard.instantiateViewControllerWithIdentifier(stringID) as! UIViewController
        self.showViewController(viewC, sender: self)
    }
    
    func loadSisters() {
        var chars: [Character] = ["(", ")", "-", " "]
        var firstName = "Nombre"
        var lastName = "Apellido"
        var congregation = "Congregacion"
        var homePhone = "Telefono de Casa"
        var cellPhone = "Telefono Movil"
        var email = "Correo Electronico"
        var friday = "Viernes"
        var saturday = "Sabado"
        var sunday = "Domingo"
        
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .NoStyle
        timeFormatter.timeStyle = .ShortStyle
        
        var urlPath = NSBundle.mainBundle().pathForResource("Horario", ofType: "csv")
        if let url = NSURL.fileURLWithPath(urlPath!) {
            //println("Url: \(url)")
            var error: NSErrorPointer = nil
            if let csv = CSV(contentsOfURL: url, error: error) {
                // Run through entire csv file
                
                for var i = 0; i < csv.rows.count; i++ {
                    // Rows
                    let sisterInf = csv.rows[i]
                    
                    // Sister Info to be saved
                    var pSisterInfo:SisterInfo
                    pSisterInfo = SisterInfo()
                    
                    if let firstNameStr = sisterInf[firstName] {
                        if firstNameStr != "" {
                            pSisterInfo.firstName = firstNameStr
                        }
                    }
                    
                    if let lastNameStr = sisterInf[lastName] {
                        if lastNameStr != "" {
                            pSisterInfo.lastName = lastNameStr
                        }
                    }
                    
                    var cellPhoneStr = removeCharacters(sisterInf[cellPhone]!, charSet: chars)
                    if cellPhoneStr != "" {
                        pSisterInfo.phoneNumber = cellPhoneStr.toInt()
                    }
                    
                    var homePhoneStr = removeCharacters(sisterInf[homePhone]!, charSet: chars)
                    if homePhoneStr != "" {
                        pSisterInfo.housePhone = homePhoneStr.toInt()
                    }
                    
                    if let congregationStr = sisterInf[congregation] {
                        pSisterInfo.congregation = congregationStr
                    }
                    
                    if let emailStr = sisterInf[email] {
                        pSisterInfo.email = emailStr
                    }
                    
                    if let fridayStr = sisterInf[friday] {
                        if fridayStr != "" || fridayStr != " " {
                            var fridayD = createDate(friday, time: fridayStr)
                            pSisterInfo.fridayTime = fridayD
                        }
                    }
                    
                    if let saturdayStr = sisterInf[saturday] {
                        if saturdayStr != "" || saturdayStr != " "{
                            var saturdayD = createDate(saturday, time: saturdayStr)
                            pSisterInfo.saturdayTime = saturdayD
                        }
                    }
                    
                    if let sundayStr = sisterInf[sunday] {
                        if sundayStr != "" || sundayStr != " "{
                            var sundayD = createDate(sunday, time: sundayStr)
                            pSisterInfo.sundayTime = sundayD
                        }
                    }
                    if pSisterInfo.firstName != "" && pSisterInfo.firstName != nil && pSisterInfo.lastName != "" && pSisterInfo.lastName != nil{
                        pSisterInfo.saveSisterInfo()
                        println("Name: \(pSisterInfo.firstName!) \(pSisterInfo.lastName!)")
                    }
                }
            }
        }
    }
    
    func createDate(day:String, time:String) -> NSDate? {
        var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        var dateComp = NSDateComponents()
        dateComp.year = 2015
        dateComp.month = 6
        
        switch day {
        case "Viernes":
            dateComp.day = 12
        case "Sabado":
            dateComp.day = 13
        case "Domingo":
            dateComp.day = 14
        default:
            println("Not a day")
        }
        // Get minutes and hours
        var splitStr = [String]()
        if (time as NSString).containsString("-") {
            var split = time.componentsSeparatedByString("-")
            splitStr = split[0].componentsSeparatedByString(":")
        }
        else {
            splitStr = time.componentsSeparatedByString(":")
        }
        var hourStr = splitStr[0].toInt()
        if hourStr == nil {
            return nil
        }
        if hourStr <= 6 {
            hourStr! += 12
        }
        println("Hour: \(hourStr!)")
        var tempStr = removeCharacters(splitStr[1], charSet: [" "])
        var minuteStr = tempStr.toInt()
        println("Minute: \(minuteStr!)")
        
        dateComp.hour = hourStr!
        dateComp.minute = minuteStr!
        
        return (calendar?.dateFromComponents(dateComp))!
    }
    
    // Remove certain characters
    func removeCharacters(number:String, charSet:[Character]) -> String {
        return String(filter(number) {find(charSet, $0) == nil})
    }
    
    // Action for when the "Proceder" button has been pressed
    @IBAction func procedeAction(sender: AnyObject) {
        //loadSisters()
        // Check all sisters have their name on the list
        
        ObjectIdDictionary.sharedInstance.updateSisterIdDict{(success:Bool, sisDict:[String:String]?) -> Void in
            if success {
                println("This is how many sisters there are here: \(sisDict?.keys.array)")
            }
            else {
                println("Couldn't get the sisDict")
            }
        }
        /*
        // If iPhone then user fingerprint to login
        if deviceInterface == .Phone {
            requestFingerprintAuthentication()
        }
        else if deviceInterface == .Pad {
            showVC("AuthenticationVC") // If iPad then go to QRAuthentication
            /*let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SideBarController") as! AVSideBarController
            self.showViewController(vc, sender: self)*/
        }*/
    }

}
