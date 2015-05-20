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
    let className:String! = "ObjectIdDictionary"
    // Name to call and save sistersDict
    let sistersString:String! = "sistersInfo"
    // Object ID  for sisters Dict saved on parse.com
    let sisterDictID:String! = "123"
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
    
    init() {
        var query = PFQuery(className: className)
        query.getObjectInBackgroundWithId(sisterDictID, block: {(sistersDict: PFObject?, error: NSError?) -> Void in
            if sistersDict != nil {
                self.sistersDictObject = sistersDict
                self.sistersDictionary = self.sistersDictObject![self.sistersString] as! [String:String]
                println("Retrieved sisters Dict")
            }
            else {
                println("Error \(error?.localizedDescription)")
            }
        })
    }
    
    func saveSisterID(objectID: String, sisterName: String) {
        sistersDictionary = [sisterName: objectID]
        sistersDictObject?[sistersString] = sistersDictionary
    }
    
    func saveMapPontID(objectID: String, mapPointNumber: Int) {
        mapPointDictionary = [mapPointNumber: objectID]
        mapPointDictObject?[mapPointString] = mapPointDictionary
    }
}
