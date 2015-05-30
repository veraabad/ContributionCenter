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
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)
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
        set (number) { self.sisterObject?["phoneNumber"] = number }
    }
    var housePhone: Int? {
        get { return sisterObject?["housePhone"] as? Int }
        set (number) { sisterObject?["housePhone"] = number }
    }
    var congregation: String? {
        get { return sisterObject?["congregation"] as? String }
        set (name) { sisterObject?["congregation"] = name }
    }
    var fridayTime: NSDate? {
        get { return sisterObject?["fridayTime"] as? NSDate }
        set (friday) { sisterObject?["fridayTime"] = friday }
    }
    var saturdayTime: NSDate? {
        get { return sisterObject?["saturdayTime"] as? NSDate}
        set (saturday) { sisterObject?["saturdayTime"] = saturday }
    }
    var sundayTime: NSDate? {
        get { return sisterObject?["sundayTime"] as? NSDate }
        set (sunday) { sisterObject?["sundayTime"] = sunday }
    }
    var boxAssigned: Int? {
        get { return sisterObject?["boxAssigned"] as? Int}
        set (box) {
            boxesAssignedHolder.append(box!)
            self.boxesAssigned = boxesAssignedHolder
            sisterObject?["boxAssigned"] = box
        }
    }
    private(set) var boxesAssigned: [Int]? {
        get { return sisterObject?["boxesAssigned"] as? [Int] }
        set (boxes) { sisterObject?["boxesAssigned"] = boxes }
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
    func fetchSisterInfo() {
        dispatch_group_enter(fetchExistingSis)
        sisterObject?.fetchInBackgroundWithBlock{(successObj:PFObject?, error:NSError?) -> Void in
            if successObj != nil {
                self.sisterObject = successObj
                if let boxes = self.boxesAssigned {
                    self.boxesAssignedHolder = boxes
                }
            }
            else {
                println("Error: \(error?.userInfo)")
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
                println("Sister ID is: \(sisID)")
                var query = PFQuery(className: self.className)
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
                        println("Error: \(error?.userInfo)")
                    }
                    dispatch_group_leave(self.fetchExistingSis) // Exit dispatch group
                })
            }
                // If no object id found then the name has not been saved
            else {
                println("Error name does not exist")
            }
        }
    }
    
    // Save the sisterInfo PFObject
    func saveSisterInfo() {
        // Find out if the object existed already or not
        dispatch_group_notify(fetchExistingSis, GlobalMainQueue){
            if self.existing {
                if self.sisterObject?.isDirty() == true {
                    println("Sister object \(self.sisterObject)")
                    self.sisterObject?.saveInBackground()
                }
            }
            else {
                self.sisterObject?.saveInBackgroundWithBlock{( success:Bool, error: NSError?) -> Void in
                    if success {
                        println("Saved sister's info")
                        ObjectIdDictionary.sharedInstance.saveSisterID((self.sisterObject?.objectId)!, sisterName: String(self.firstName! + " " + self.lastName!))
                    }
                    else {
                        println("Error: \(error?.userInfo)")
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
    
    var boxNumber: Int {
        get { return boxesObject?["boxNumber"] as! Int }
        set (boxNum) { boxesObject?["boxNumber"] = boxNum }
    }
    
    var sisterAssigned: String? {
        get { return boxesObject?["sisterAssigned"] as? String}
        set (sisAssigned) { boxesObject?["sisterAssigned"] = sisAssigned }
    }
    
    init(boxNum: Int?) {
        if boxNum != nil {
            getBoxInfo(boxNum!)
        }
        else {
            boxesObject = PFObject(className: className)
        }
    }
    
    func updateBoxInfo() {
        boxesObject?.fetch()
    }
    
    func getBoxInfo(boxNum: Int) {
        // Retrieve the object id that pertains to the boxinfo
    }
    
    // Save the boxInfo
    func saveBoxInfo() {
        boxesObject?.saveInBackgroundWithBlock{( success:Bool, error: NSError?) -> Void in
            if success {
                println("Saved boxes info")
            }
            else {
                println("Error: \(error?.userInfo)")
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
                var query = PFQuery(className: self.className)
                query.getObjectInBackgroundWithId(mapPointID!, block: {(mapPointObj: PFObject?, error: NSError?) -> Void in
                    if mapPointObj != nil {
                        self.mapPointObject = mapPointObj
                    }
                    else {
                        println("Error: \(error?.userInfo)")
                    }
                    dispatch_group_leave(self.fetchExistingMapPoint) // Leave dispatch group
                })
            }
                // If no object ID found then the mapPoint has not been saved
            else {
                println("Error mapPoint doesn't exist")
            }
        }
    }
    
    // Save the mapPoint PFObject
    func saveMapPointInfo() {
        mapPointObject?.saveInBackgroundWithBlock{( success:Bool, error:NSError?) -> Void in
            if success {
                println("Saved map info")
                ObjectIdDictionary.sharedInstance.saveMapPontID((self.mapPointObject?.objectId)!, mapPointNumber: self.mapPointNumber)
            }
            else {
                println("Error: \(error?.userInfo)")
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
    
    // Class name for this PFObject
    let className:String! = "ObjectIdDictionary"
    
    // Name to call and save sistersDict
    let sistersString:String! = "sistersInfo"
    // Object ID  for sisters Dict saved on parse.com
    let sisterDictID:String! = "kR40tTKTma"
    // PFObject needed to interface with parse.com
    var sistersDictObject: PFObject?
    // SistersDict with objectID and their respective usernames
    var sistersDictionary = [String: String]()
    
    // MapPoint dictionary to calIntl and save mapPointDict
    let mapPointString:String! = "mapPointInfo"
    // Object ID for mapPoint Dict saved on parse.com
    let mapPointDictID:String! = "sXiNzEEp45"
    // PFObject needed to interface with parse.com
    var mapPointDictObject: PFObject?
    // MapPointDict with objectID and their respective mapPoint
    var mapPointDictionary:[String: String]? = [String: String]()
    
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
    }
    
    // Obtain sister object ID
    func getSisterId(name: String, success:(sisID:String?) -> Void) {
        // Update the sisterIDDictionary just in case it has been updated
        updateSisterIdDict()
        
        // Wait until the sistersDictionary has been updated
        dispatch_group_notify(fetchSisDictID, GlobalMainQueue) {
            // Get the sisters object ID for her user name
            println("SisDict: \(self.sistersDictionary)")
            var sister = self.sistersDictionary[name]
            if sister != nil {
                println("Got the ID: \(sister)")
                success(sisID: sister)
            }
            else {
                success(sisID: nil)
            }
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
                println("Retrieved sisters Dict")
                if let sisterID = self.sistersDictionary["Cecilia Vera"] {
                    println("Found sister ID: \(sisterID)")
                }
            }
            else {
                println("Erro: \(error?.userInfo)")
            }
            dispatch_group_leave(self.fetchSisDictID)
        }
    }
    
    private func getSisterIdDict() {
        // Get sister dictionary
        var query = PFQuery(className: className)
        //dispatch_group_enter(fetchSisDictID)
        query.getObjectInBackgroundWithId(sisterDictID, block: {(sistersDict: PFObject?, error: NSError?) -> Void in
            if sistersDict != nil {
                self.sistersDictObject = sistersDict
                self.sistersDictionary = self.sistersDictObject?[self.sistersString] as! [String:String]
            }
            else {
                println("Error \(error?.userInfo)")
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
                println("Saved objectID for sister")
            }
            else {
                println("Error: \(error?.userInfo)")
            }
        }
    }
    
    func getMapPointId(mapPointNumber: Int, success:(mapPointID:String?) -> Void) {
        // Update the mapPointIDDictionary just in case it has been updated
        updateMapPointIdDict()
        
        // Wait until the mapPointDictionary has been updated
        dispatch_group_notify(fetchMapPointDictID, GlobalMainQueue) {
            // Get the mapPoint object ID
            if let mapPointId = self.mapPointDictionary?[String(mapPointNumber)] {
                println("Got the mapPoint ID: \(mapPointId)")
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
                    println("Got the mapPoint Dictionary")
                }
            }
            else {
                println("Error: \(error?.userInfo)")
            }
            dispatch_group_leave(self.fetchMapPointDictID) // Leave dispatch group
        }
    }
    
    private func getMapPointIdDict() {
        // Get mapPoint dictionary
        var query = PFQuery(className: className)
        query.getObjectInBackgroundWithId(mapPointDictID, block: {(mapPointDict: PFObject?, error: NSError?) -> Void in
            if mapPointDict != nil {
                self.mapPointDictObject = mapPointDict
                self.mapPointDictionary = self.mapPointDictObject?[self.sistersString] as? [String: String]
                println("Retrieved mapPoint Dict")
            }
            else {
                println("Error \(error?.userInfo)")
            }
        })
    }
    
    // Save a new objectID for a mapPoint
    func saveMapPontID(objectID: String, mapPointNumber: Int) {
        mapPointDictionary = [String(mapPointNumber): objectID]
        mapPointDictObject?[mapPointString] = mapPointDictionary
        mapPointDictObject?.saveInBackgroundWithBlock{(success:Bool, error: NSError?) -> Void in
            if success {
                println("Saved objectID for mapPoint")
            }
            else {
                println("Error \(error?.userInfo)")
            }
        }
    }
}
