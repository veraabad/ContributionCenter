//
//  ParseHelper.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/19/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import Foundation

var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
}

// Class to handle info for Sisters helping out at the boxes
class SisterInfo {
    // Class name for this PFObject
    private let className:String! = "SisterInfo"
    // Hold array of boxes previously assigned to sister
    private var boxesAssignedHolder = [Int]()
    // Holds PFObject
    private var sisterObject: PFObject?
    // If an existing object is created then this is true
    private var existing: Bool = false
    
    // Dispatch group to know when things are done
    private var fetchExistingSis = dispatch_group_create()
    
    // Variables to hold instances of the sisters names and other info
    var firstName:String? {
        get { return sisterObject?["firstName"] as? String }
        set (name) { sisterObject?["firstName"] = name }
    }

    var lastName:String? {
        get { return sisterObject?["lastName"] as? String }
        set (name) { sisterObject?["lastName"] = name }
    }
    var email: String? {
        get { return sisterObject?["email"] as? String }
        set (email) { sisterObject?["email"] = email }
    }
    var phoneNumber: Int? {
        get { return sisterObject?["phoneNumber"] as? Int }
        set (number) {
            if number == nil{
                sisterObject?.removeObjectForKey("phoneNumber")
            }
            else {
                self.sisterObject?["phoneNumber"] = number
            }
        }
    }
    var housePhone: Int? {
        get { return sisterObject?["housePhone"] as? Int }
        set (number) {
            if number == nil{
                sisterObject?.removeObjectForKey("housePhone")
            }
            else {
                self.sisterObject?["housePhone"] = number
            }
        }
    }
    var congregation: String? {
        get { return sisterObject?["congregation"] as? String }
        set (name) { sisterObject?["congregation"] = name }
    }
    var fridayTime: NSDate? {
        get { return sisterObject?["fridayTime"] as? NSDate }
        set (friday) {
            if friday == nil{
                sisterObject?.removeObjectForKey("fridayTime")
            }
            else {
                self.sisterObject?["fridayTime"] = friday
            }
        }
    }
    var saturdayTime: NSDate? {
        get { return sisterObject?["saturdayTime"] as? NSDate}
        set (saturday) {
            if saturday == nil{
                sisterObject?.removeObjectForKey("saturdayTime")
            }
            else {
                self.sisterObject?["saturdayTime"] = saturday
            }
        }
    }
    var sundayTime: NSDate? {
        get { return sisterObject?["sundayTime"] as? NSDate }
        set (sunday) {
            if sunday == nil{
                sisterObject?.removeObjectForKey("sundayTime")
            }
            else {
                self.sisterObject?["sundayTime"] = sunday
            }
        }
    }
    var boxAssigned: Int? {
        get { return sisterObject?["boxAssigned"] as? Int}
        set (box) {
            if box == nil {
                sisterObject?.removeObjectForKey("boxAssigned")
            }
            else {
            boxesAssignedHolder.append(box!)
            self.boxesAssigned = boxesAssignedHolder
            sisterObject?["boxAssigned"] = box
            }
        }
    }
    private(set) var boxesAssigned: [Int]? {
        get { return sisterObject?["boxesAssigned"] as? [Int] }
        set (boxes) { sisterObject?["boxesAssigned"] = boxes }
    }
    
    var dirty: Bool? {
        return sisterObject?.isDirty()
    }
    
    
    // At initialization with existing sister
    init(sisterName: String, withBlock:(success:Bool) -> Void) {
        // If a sisters name has been provided then retrieve the info
        getSisterInfo(sisterName)
        dispatch_group_notify(fetchExistingSis, GlobalMainQueue) {
            // Sister was found
            if self.existing {
                withBlock(success: true)
            }
            // Sister was not found
            else {
                withBlock(success: false)
            }
        }
    }
    
    // At initiallization with new sister
    init ()  {
        sisterObject = PFObject(className: className)
        existing = false
    }
    
    // Fetch any new changes that have been saved on the server
    func fetchSisterInfo(block:(success:Bool) -> Void) {
        dispatch_group_enter(fetchExistingSis)
        sisterObject?.fetchInBackgroundWithBlock{(successObj:PFObject?, error:NSError?) -> Void in
            if successObj != nil {
                self.sisterObject = successObj
                if let boxes = self.boxesAssigned {
                    self.boxesAssignedHolder = boxes
                }
                block(success: true)
            }
            else {
                print("Error: \(error?.userInfo)")
                block(success: false)
            }
            dispatch_group_leave(self.fetchExistingSis)
        }
    }
    
    func getSisterInfo(sisName: String) {
        // Retrieve the object id that pertains to the sisters name
        // Enter dispatch group to see when it will be done
        dispatch_group_enter(fetchExistingSis)
        ObjectIdDictionary.sharedInstance.getSisterId(sisName) {(sisID) -> Void in
            if sisID != nil {
                print("Sister ID is: \(sisID)")
                let query = PFQuery(className: self.className)
                query.getObjectInBackgroundWithId(sisID!, block: {(sisObject: PFObject?, error: NSError?) -> Void in
                    // If a PFObject is found then save it and try to retrieve the boxesAssigned array
                    if sisObject != nil {
                        self.existing = true
                        self.sisterObject = sisObject
                        if let boxes = self.boxesAssigned {
                            self.boxesAssignedHolder = boxes
                        }
                    }
                    else {
                        print("Error: \(error?.userInfo)")
                        self.existing = false
                    }
                    dispatch_group_leave(self.fetchExistingSis) // Exit dispatch group
                })
            }
                // If no object id found then the name has not been saved
            else {
                print("Error name does not exist")
                dispatch_group_leave(self.fetchExistingSis)
                self.existing = false
            }
        }
    }
    
    // Save the sisterInfo PFObject
    func saveSisterInfo() {
        // Find out if the object existed already or not
        dispatch_group_notify(fetchExistingSis, GlobalMainQueue){
            if self.existing {
                if self.sisterObject?.isDirty() == true {
                    print("Sister object \(self.sisterObject)")
                    self.sisterObject?.saveInBackground()
                }
            }
            else {
                self.sisterObject?.saveInBackgroundWithBlock{( success:Bool, error: NSError?) -> Void in
                    if success {
                        print("Saved sister's info")
                        ObjectIdDictionary.sharedInstance.saveSisterID((self.sisterObject?.objectId)!, sisterName: String(self.firstName! + " " + self.lastName!))
                    }
                    else {
                        print("Error: \(error?.userInfo)")
                    }
                }
            }
        }
    }
}

// Class to handle info for Boxes Out and link them to the sister handling the box
class BoxesOut {
    // Variable to hold instances of the box info
    private var boxesObject: PFObject?
    private let className: String! = "BoxesOut"
    // If an existing object is created then this is true
    private var existing:Bool = false
    
    // Dispatch group to know when things are donw
    private var fetchExistingBox = dispatch_group_create()
    
    var boxNumber: Int {
        get { return boxesObject?["boxNumber"] as! Int }
        set (boxNum) { boxesObject?["boxNumber"] = boxNum }
    }
    
    var sisterAssigned: String? {
        get { return boxesObject?["sisterAssigned"] as? String}
        set (sisAssigned) { boxesObject?["sisterAssigned"] = sisAssigned }
    }
    
    var dirty: Bool? {
        return boxesObject?.isDirty()
    }
    
    // Initialize a new boxObject
    init () {
        boxesObject = PFObject(className: className)
        existing = false
    }
    
    // Initialize with an existing boxObject
    init(boxNum: Int?, withBlock:(success:Bool) -> Void) {
        getBoxInfo(boxNum!)
        dispatch_group_notify(fetchExistingBox, GlobalMainQueue) {
            // Box was found
            if self.existing {
                withBlock(success: true)
            }
            // Box was not found
            else {
                withBlock(success: false)
            }
        }
    }
    
    // Fetch any new changes that have been saved on the server
    func fetchBoxInfo(block:(success:Bool) -> Void) {
        dispatch_group_enter(fetchExistingBox)
        boxesObject?.fetchInBackgroundWithBlock{(successObj:PFObject?, error:NSError?) -> Void in
            if successObj != nil {
                self.boxesObject = successObj
                // Report the success
                block(success: true)
            }
            else {
                print("Error: \(error?.userInfo)")
                block(success: false)
            }
            dispatch_group_leave(self.fetchExistingBox)
        }
    }
    
    func getBoxInfo(boxNum: Int) {
        // Retrieve the object id that pertains to the boxinfo
        // Enter dispatch group to see when it will be done
        dispatch_group_enter(fetchExistingBox)
        ObjectIdDictionary.sharedInstance.getBoxId(boxNum) {(boxID) -> Void in
            if boxID != nil {
                let query = PFQuery(className: self.className)
                query.getObjectInBackgroundWithId(boxID!, block: {(boxObj: PFObject?, error:NSError?) -> Void in
                    // If a PFObject is found then save it
                    if boxObj != nil {
                        self.existing = true
                        self.boxesObject = boxObj
                    }
                    else {
                        print("Error: \(error?.userInfo)")
                    }
                    dispatch_group_leave(self.fetchExistingBox) // Exit dispatch group
                })
            }
            else {
                print("Error box does not exist")
            }
        }
    }
    
    // Save the boxInfo
    func saveBoxInfo() {
        // Find out if the object existed already or not
        dispatch_group_notify(fetchExistingBox, GlobalMainQueue) {
            if self.existing {
                if (self.boxesObject?.isDirty())! {
                    self.boxesObject?.saveInBackground()
                }
            }
            else {
                self.boxesObject?.saveInBackgroundWithBlock{( success:Bool, error: NSError?) -> Void in
                    if success {
                        print("Saved boxes info")
                        ObjectIdDictionary.sharedInstance.saveBoxID((self.boxesObject?.objectId)!, boxNumber: self.boxNumber)
                    }
                    else {
                        print("Error: \(error?.userInfo)")
                    }
                }
            }
        }
    }
    
}

// Class to handle info about position of Qualcomm stadium map
class MapPoint {
    private var mapPointObject: PFObject?
    private let className:String! = "MapPoint"
    // Lets us know when certain async tasks have completed
    private var fetchExistingMapPoint = dispatch_group_create()
    
    // Holds mapPoint data
    var mapPoint: NSData? {
        get { return mapPointObject?["mapPoint"] as? NSData }
        set (mapP) { mapPointObject?["mapPoint"] = mapP }
    }
    
    var mapPointNumber: Int {
        get { return mapPointObject?["mapPointNumber"] as! Int }
        set (mapPointNum) { mapPointObject?["mapPointNumber"] = mapPointNum }
    }
    
    init(mapPointNum:Int?) {
        if mapPointNum != nil {
            getMapPointInfo(mapPointNum!)
        }
        else {
            mapPointObject = PFObject(className: className)
        }
    }
    
    func updateMapPointInfo() {
        mapPointObject?.fetch()
    }
    
    // Retrieve an existing mapPointObject if it does exist
    func getMapPointInfo(mapPointNum: Int) {
        // Enter dispatch group to see when it will be done
        // Retrieve the object id that pertains to the mapPointNumber
        dispatch_group_enter(fetchExistingMapPoint) // Enter dispatch group
        ObjectIdDictionary.sharedInstance.getMapPointId(mapPointNum) {(mapPointID) -> Void in
            if mapPointID != nil {
                let query = PFQuery(className: self.className)
                query.getObjectInBackgroundWithId(mapPointID!, block: {(mapPointObj: PFObject?, error: NSError?) -> Void in
                    if mapPointObj != nil {
                        self.mapPointObject = mapPointObj
                    }
                    else {
                        print("Error: \(error?.userInfo)")
                    }
                    dispatch_group_leave(self.fetchExistingMapPoint) // Leave dispatch group
                })
            }
                // If no object ID found then the mapPoint has not been saved
            else {
                print("Error mapPoint doesn't exist")
            }
        }
    }
    
    // Save the mapPoint PFObject
    func saveMapPointInfo() {
        mapPointObject?.saveInBackgroundWithBlock{( success:Bool, error:NSError?) -> Void in
            if success {
                print("Saved map info")
                ObjectIdDictionary.sharedInstance.saveMapPontID((self.mapPointObject?.objectId)!, mapPointNumber: self.mapPointNumber)
            }
            else {
                print("Error: \(error?.userInfo)")
            }
        }
    }
}

// Class holds an NSDictionary for usersName and objectId
class ObjectIdDictionary {
    
    // Find out when were done fetching sisDictID
    private var fetchSisDictID = dispatch_group_create()
    // Find out when were done fetching mapPointDictID
    private var fetchMapPointDictID = dispatch_group_create()
    // Find out when were done fetching boxInfoDictID
    private var fetchBoxInfoDictID = dispatch_group_create()
    
    // Class name for this PFObject
    private let className:String! = "ObjectIdDictionary"
    
    // Sister Variables
    // Name to call and save sistersDict
    private let sistersString:String! = "sistersInfo"
    // Object ID  for sisters Dict saved on parse.com
    private let sisterDictID:String! = "kR40tTKTma"
    // PFObject needed to interface with parse.com
    private var sistersDictObject: PFObject?
    // SistersDict with objectID and their respective usernames
    var sistersDictionary = [String: String]()
    var sisStartTime:NSDate? = NSDate()
    
    // MapPoint Variables
    // MapPoint dictionary to call and save mapPointDict
    private let mapPointString:String! = "mapPointInfo"
    // Object ID for mapPoint Dict saved on parse.com
    private let mapPointDictID:String! = "sXiNzEEp45"
    // PFObject needed to interface with parse.com
    private var mapPointDictObject: PFObject?
    // MapPointDict with objectID and their respective mapPoint
    var mapPointDictionary:[String: String]? = [String: String]()
    
    // BoxInfo Variables
    // BoxInfo dictionary to call and save
    private let boxInfoString:String! = "boxInfo"
    // Object ID for boxInfo Dict saved on parse.com
    private let boxInfoDictID:String! = "KicKz5lea7"
    // PFObject needed to interface with parse.com
    private var boxInfoDictObject: PFObject?
    // BoxesDict with objectID and their respective number
    var boxesDictionary = [String: String]()
    
    // Singleton for ObjectIdDictionary
    class var sharedInstance: ObjectIdDictionary {
        struct Static {
            static var instance: ObjectIdDictionary?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ObjectIdDictionary()
        }
        
        return Static.instance!
    }

    
    // At initialization obtain objectId dictionaries for sisters and mapPoints
    init() {
        // Obtain sisterIdDict if available
        getSisterIdDict()
        
        // Obtain mapPointIdDict if available
        getMapPointIdDict()
        
        // Obtain boxesDictionary
        getBoxIdDict()
    }
    
    // MARK:
    // Sister Object ID functions
    
    // Obtain sister object ID
    func getSisterId(name: String, success:(sisID:String?) -> Void) {
        // Update the sisterIDDictionary just in case it has been updated
        let end = NSDate()
        let dateComponents: NSDateComponents = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.components(NSCalendarUnit.Second, fromDate: sisStartTime!, toDate: end, options: NSCalendarOptions())
        if dateComponents.second > 60 {
            updateSisterIdDict()
        }
        
        // Wait until the sistersDictionary has been updated
        dispatch_group_notify(fetchSisDictID, GlobalMainQueue) {
            // Get the sisters object ID for her user name
            //println("SisDict: \(self.sistersDictionary)")
            let sister = self.sistersDictionary[name]
            if sister != nil {
                //println("Got the ID: \(sister)")
                success(sisID: sister)
            }
            else {
                success(sisID: nil)
            }
        }
    }
    
    // Update the sisterDictObject just in case there has been an addition
    func updateSisterIdDict(success:(updateSuccess:Bool, sistersDict: [String:String]?) -> Void) {
        dispatch_group_enter(fetchSisDictID)
        sistersDictObject?.fetchInBackgroundWithBlock{(sisDict: PFObject?, error:NSError?) -> Void in
            if sisDict != nil {
                self.sistersDictObject = sisDict
                if let sisDict = self.sistersDictObject?[self.sistersString] as? [String:String] {
                    self.sistersDictionary = sisDict
                    // If we could obtain the dictionary then pass that back
                    success(updateSuccess: true, sistersDict: self.sistersDictionary)
                }
                // Test the dictionary
                print("Retrieved sisters Dict")
                if let sisterID = self.sistersDictionary["Cecilia Vera"] {
                    print("Found sister ID: \(sisterID)")
                }
            }
            else {
                print("Error: \(error?.userInfo)")
                // If not successful then send results back
                success(updateSuccess: false, sistersDict: nil)
            }
            dispatch_group_leave(self.fetchSisDictID)
        }
    }
    
    // Update the sisterDictObject just in case there has been an addition
    private func updateSisterIdDict() {
        dispatch_group_enter(fetchSisDictID)
        sistersDictObject?.fetchInBackgroundWithBlock{(sisDict: PFObject?, error:NSError?) -> Void in
            if sisDict != nil {
                self.sistersDictObject = sisDict
                self.sistersDictionary = self.sistersDictObject?[self.sistersString] as! [String:String]
                // Test the dictionary
                print("Retrieved sisters Dict")
                self.sisStartTime = NSDate()
            }
            else {
                print("Error: \(error?.userInfo)")
            }
            dispatch_group_leave(self.fetchSisDictID)
        }
    }
    
    private func getSisterIdDict() {
        // Get sister dictionary
        let query = PFQuery(className: className)
        //dispatch_group_enter(fetchSisDictID)
        query.getObjectInBackgroundWithId(sisterDictID, block: {(sistersDict: PFObject?, error: NSError?) -> Void in
            if sistersDict != nil {
                self.sistersDictObject = sistersDict
                if let sisDict = self.sistersDictObject?[self.sistersString] as? [String:String] {
                    self.sistersDictionary = sisDict
                    self.sisStartTime = NSDate()
                }
            }
            else {
                print("Error \(error?.userInfo)")
            }
            //dispatch_group_leave(self.fetchSisDictID)
        })
    }
    
    // Save a new object ID for a sister
    func saveSisterID(objectID: String, sisterName: String) {
        sistersDictionary[sisterName] = objectID
        sistersDictObject?[sistersString] = sistersDictionary
        sistersDictObject?.saveInBackgroundWithBlock{(success:Bool, error: NSError?) -> Void in
            if success {
                print("Saved objectID for sister")
            }
            else {
                print("Error: \(error?.userInfo)")
            }
        }
    }
    
    // MARK:
    // Map Point ObjectID functions
    
    func getMapPointId(mapPointNumber: Int, success:(mapPointID:String?) -> Void) {
        // Update the mapPointIDDictionary just in case it has been updated
        updateMapPointIdDict()
        
        // Wait until the mapPointDictionary has been updated
        dispatch_group_notify(fetchMapPointDictID, GlobalMainQueue) {
            // Get the mapPoint object ID
            if let mapPointId = self.mapPointDictionary?[String(mapPointNumber)] {
                print("Got the mapPoint ID: \(mapPointId)")
                success(mapPointID: mapPointId)
            }
            else {
                success(mapPointID: nil)
            }
        }
    }
    
    private func updateMapPointIdDict() {
        // Get mapPoint dictionary
        // Enter into a dispatch group to find out when the block will finish
        dispatch_group_enter(fetchMapPointDictID)
        mapPointDictObject?.fetchInBackgroundWithBlock{(mapPointDictObj:PFObject?, error:NSError?) -> Void in
            if mapPointDictObj != nil {
                self.mapPointDictObject = mapPointDictObj
                if let mapDict = self.mapPointDictObject?[self.mapPointString] as? [String:String] {
                    self.mapPointDictionary = mapDict
                    print("Got the mapPoint Dictionary")
                }
            }
            else {
                print("Error: \(error?.userInfo)")
            }
            dispatch_group_leave(self.fetchMapPointDictID) // Leave dispatch group
        }
    }
    
    private func getMapPointIdDict() {
        // Get mapPoint dictionary
        let query = PFQuery(className: className)
        query.getObjectInBackgroundWithId(mapPointDictID, block: {(mapPointDict: PFObject?, error: NSError?) -> Void in
            if mapPointDict != nil {
                self.mapPointDictObject = mapPointDict
                self.mapPointDictionary = self.mapPointDictObject?[self.sistersString] as? [String: String]
                print("Retrieved mapPoint Dict")
            }
            else {
                print("Error \(error?.userInfo)")
            }
        })
    }
    
    // Save a new objectID for a mapPoint
    func saveMapPontID(objectID: String, mapPointNumber: Int) {
        mapPointDictionary = [String(mapPointNumber): objectID]
        mapPointDictObject?[mapPointString] = mapPointDictionary
        mapPointDictObject?.saveInBackgroundWithBlock{(success:Bool, error: NSError?) -> Void in
            if success {
                print("Saved objectID for mapPoint")
            }
            else {
                print("Error \(error?.userInfo)")
            }
        }
    }
    
    // MARK:
    // Box Info ObjectID functions
    
    // Obtain box object ID
    func getBoxId(boxNumber: Int, success:(boxID:String?) -> Void) {
        // Update the boxesDictionary just in case it has been updated
        updateBoxIdDict()
        
        // Wait until the boxesDictionary has been updated
        dispatch_group_notify(fetchBoxInfoDictID, GlobalMainQueue) {
            // Get the boxes object ID for box number
            if let box = self.boxesDictionary[String(boxNumber)] {
                success(boxID: box)
            }
            else {
                success(boxID: nil)
            }
        }
    }
    
    // Update the boxInfoDictObject just in case there has been an addition
    func updateBoxIdDict(success:(updateSuccess:Bool, boxDict: [String:String]?) -> Void) {
        dispatch_group_enter(fetchBoxInfoDictID)
        boxInfoDictObject?.fetchInBackgroundWithBlock{(boxDict: PFObject?, error:NSError?) -> Void in
            if boxDict != nil {
                print("Found boxInfoDictObject")
                self.boxInfoDictObject = boxDict
                if let boxesDict = self.boxInfoDictObject?[self.boxInfoString] as? [String:String] {
                    print("Got boxesDictionary")
                    self.boxesDictionary = boxesDict
                    // If we could obtain the dictionary then pass that back
                    success(updateSuccess: true, boxDict: self.boxesDictionary)
                }
            }
            else {
                print("Error: \(error?.userInfo)")
                // If not succesful then send results back
                success(updateSuccess: false, boxDict: nil)
            }
            dispatch_group_leave(self.fetchBoxInfoDictID)
        }
    }
    
    // Update the boxInfoDictObject just in case there has been an additions
    private func updateBoxIdDict() {
        dispatch_group_enter(fetchBoxInfoDictID)
        boxInfoDictObject?.fetchInBackgroundWithBlock{(boxDict: PFObject?, error:NSError?) -> Void in
            if boxDict != nil {
                self.boxInfoDictObject = boxDict
                if let boxesDict = self.boxInfoDictObject?[self.boxInfoString] as? [String:String] {
                    self.boxesDictionary = boxesDict
                }
            }
            else {
                print("Error: \(error?.userInfo)")
            }
            dispatch_group_leave(self.fetchBoxInfoDictID)
        }
    }
    
    // Get boxesDictionary from parse server
    private func getBoxIdDict() {
        // Get box dictionary
        let query = PFQuery(className: className)
        
        query.getObjectInBackgroundWithId(boxInfoDictID, block: {(boxesDictObj:PFObject?, error:NSError?) -> Void in
            if boxesDictObj != nil {
                print("Found boxInfoDictObject")
                self.boxInfoDictObject = boxesDictObj
                // Get boxesDictionary if available
                if let boxDict = self.boxInfoDictObject?[self.boxInfoString] as? [String:String] {
                    print("Got boxesDictionary")
                    self.boxesDictionary = boxDict
                }
            }
            else {
                print("Error: \(error?.userInfo)")
            }
        })
    }
    
    // Save a new object ID for box
    func saveBoxID(objectID:String, boxNumber:Int) {
        boxesDictionary[String(boxNumber)] = objectID
        boxInfoDictObject?[boxInfoString] = boxesDictionary
        boxInfoDictObject?.saveInBackgroundWithBlock{(success:Bool, error:NSError?) -> Void in
            if success {
                print("Saved objectID for box")
            }
            else {
                print("Error: \(error?.userInfo)")
            }
        }
    }
}
