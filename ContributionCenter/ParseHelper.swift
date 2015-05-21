//
//  ParseHelper.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/19/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import Foundation

// Class to handle info for Sisters helping out at the boxes
class SisterInfo: PFObject, PFSubclassing {
    // Variables to hold instances of the sisters names and other info
    @NSManaged var firstName: String!
    @NSManaged var lastName: String!
    @NSManaged var email: String!
    @NSManaged var phoneNumber: Int
    @NSManaged var housePhone: Int
    @NSManaged var congregation: String!
    @NSManaged var fridayTime: NSDate!
    @NSManaged var saturdayTime: NSDate!
    @NSManaged var sundayTime: NSDate!
    @NSManaged var boxAssigned: Int
    @NSManaged var boxesAssigned: [Int]
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "SisterInfo"
    }
}

// Class to handle info for Boxes Out and link them to the sister handling the box
class BoxesOut: PFObject, PFSubclassing {
    // Variables to hold instances of box info
    @NSManaged var boxNumber: Int
    @NSManaged var sisterAssigned: String!
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "BoxesOut"
    }
}

// Class to handle info about position of Qualcomm stadium map
class MapPoint: PFObject, PFSubclassing {
    // Holds mapPoint data
    @NSManaged var mapPoint: NSData!
    @NSManaged var mapPointNumber: Int
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "MapPoint"
    }
}

// Class holds an NSDictionary for usersName and objectId
class ObjectIdDictionary {
    
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
    let mapPointDictID:String! = "456"
    // PFObject needed to interface with parse.com
    var mapPointDictObject: PFObject?
    // MapPointDict with objectID and their respective mapPoint
    var mapPointDictionary = [Int: String]()
    
    // At initialization obtain objectId dictionaries for sisters and mapPoints
    init() {
        var query = PFQuery(className: className)
        
        // Get sister dictionary
        query.getObjectInBackgroundWithId(sisterDictID, block: {(sistersDict: PFObject?, error: NSError?) -> Void in
            if sistersDict != nil {
                self.sistersDictObject = sistersDict
                self.sistersDictionary = self.sistersDictObject?[self.sistersString] as! [String:String]
                // Just a test of the services
                println("Retrieved sisters Dict")
                if let sisterID = self.sistersDictionary["Cristina Vera"] {
                    println("Found sister ID: \(sisterID)")
                }
            }
            else {
                println("Error \(error?.userInfo)")
            }
        })
        
        // Get mapPoint dictionary
        /*
        query.getObjectInBackgroundWithId(mapPointDictID, block: {(mapPointDict: PFObject?, error: NSError?) -> Void in
            if mapPointDict != nil {
                self.mapPointDictObject = mapPointDict
                self.mapPointDictionary = self.mapPointDictObject?[self.sistersString] as! [Int: String]
                println("Retrieved mapPoint Dict")
            }
            else {
                println("Error \(error?.userInfo)")
            }
        })*/
    }
    
    // Save a new object ID for a sister
    func saveSisterID(objectID: String, sisterName: String) {
        sistersDictionary = [sisterName: objectID]
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
    
    // Save a new objectID for a mapPoint
    func saveMapPontID(objectID: String, mapPointNumber: Int) {
        mapPointDictionary = [mapPointNumber: objectID]
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
