//
//  PrintViewController.swift
//  ContributionCenter
//
//  Created by Abad Vera on 6/12/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit
import AVFoundation

let POINTS_PER_INCH:CGFloat = 72

class PrintViewController: UIViewController {

    @IBOutlet weak var imageV1: UIImageView!
    @IBOutlet weak var imageV2: UIImageView!
    @IBOutlet weak var imageV3: UIImageView!
    @IBOutlet weak var imageV4: UIImageView!
    @IBOutlet weak var imageV5: UIImageView!
    @IBOutlet weak var imageV6: UIImageView!
    @IBOutlet weak var imageV7: UIImageView!
    @IBOutlet weak var imageV8: UIImageView!
    @IBOutlet weak var imageV9: UIImageView!
    @IBOutlet weak var imageV10: UIImageView!
    @IBOutlet weak var imageV11: UIImageView!
    @IBOutlet weak var imageV12: UIImageView!
    @IBOutlet weak var imageV13: UIImageView!
    @IBOutlet weak var imageV14: UIImageView!
    @IBOutlet weak var imageV15: UIImageView!
    @IBOutlet weak var imageV16: UIImageView!
    @IBOutlet weak var imageV17: UIImageView!
    @IBOutlet weak var imageV18: UIImageView!
    @IBOutlet weak var imageV19: UIImageView!
    @IBOutlet weak var imageV20: UIImageView!
    @IBOutlet weak var imageV21: UIImageView!
    @IBOutlet weak var imageV22: UIImageView!
    @IBOutlet weak var imageV23: UIImageView!
    @IBOutlet weak var imageV24: UIImageView!
    @IBOutlet weak var imageV25: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label9: UILabel!
    @IBOutlet weak var label10: UILabel!
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label12: UILabel!
    @IBOutlet weak var label13: UILabel!
    @IBOutlet weak var label14: UILabel!
    @IBOutlet weak var label15: UILabel!
    @IBOutlet weak var label16: UILabel!
    @IBOutlet weak var label17: UILabel!
    @IBOutlet weak var label18: UILabel!
    @IBOutlet weak var label19: UILabel!
    @IBOutlet weak var label20: UILabel!
    @IBOutlet weak var label21: UILabel!
    @IBOutlet weak var label22: UILabel!
    @IBOutlet weak var label23: UILabel!
    @IBOutlet weak var label24: UILabel!
    @IBOutlet weak var label25: UILabel!
    
    @IBOutlet weak var viewsCont: UIView!
    
    var sisterArray:[String]? = [String]()
    
    var stepAt:Int! = 0
    var tempArray:[String]? = [String]()
    
    var imageVArray = [UIImageView]()
    var labelArray = [UILabel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        imageVArray = [imageV1, imageV2, imageV3, imageV4, imageV5, imageV6, imageV7, imageV8, imageV9, imageV10, imageV11, imageV12,imageV13, imageV14, imageV15, imageV16,imageV17, imageV18, imageV19, imageV20, imageV21, imageV22, imageV23, imageV24, imageV25]
        
        labelArray = [label1, label2, label3, label4, label5, label6, label7, label8, label9, label10, label11, label12, label13, label14, label15, label16, label17, label18, label19, label20, label21, label22, label23, label24, label25]
        
        ObjectIdDictionary.sharedInstance.updateSisterIdDict{(success: Bool, sisDict: [String:String]?) -> Void in
            if success {
                self.sisterArray = [String](sisDict!.keys)
                print("Did get that Dict")
            }
            else {
                print("Couldn't get the Dict")
            }
        }
        //loadImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImages() {
        
        if tempArray != nil {
            for var i = 0; i < tempArray?.count; i++ {
                let name = tempArray?[i]
                var imageV:UIImageView = UIImageView()
                var labelStr:UILabel = UILabel()
                
                for imagev in imageVArray {
                    if imagev.tag == i + 1{
                        imageV = imagev
                    }
                }
                for label in labelArray {
                    if label.tag == i + 1{
                        labelStr = label
                    }
                }
                
                let qrCode = QRGenerator(qrString: name!, sizeRate: 3.0)
                
                imageV.image = qrCode.qrImage
                labelStr.text = name
            }
        }
    }
    
    func clear() {
        for imagev in imageVArray {
            imagev.image = UIImage()
        }
        for label in labelArray {
            label.text = ""
        }
    }
    
    @IBAction func nextBttnAction(sender: AnyObject) {
        // First get screen shot
        UIGraphicsBeginImageContext(viewsCont.frame.size)
        viewsCont.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        clear()
        // Load array 
        if sisterArray != nil {
            tempArray = [] // Clear Array
            for var i = 0; i < 25; i++ {
                if (i + stepAt) < sisterArray!.count {
                    if let name = sisterArray?[i + stepAt] {
                        tempArray! += [name]
                    }
                }
            }
            print("TempArray \(tempArray)")
            stepAt! += 25 // Add 25 after loading
        }
        loadImages()
    }
}

class QRandNamePageRenderer: UIPrintPageRenderer {
    var qrCode:UIImage!
    var sisName: String!
    
    init (qr:UIImage, name: String) {
        qrCode = qr
        sisName = name
        super.init()
        
        //self.headerHeight = 0.5 * POINTS_PER_INCH
        self.headerHeight = 0.0
        self.footerHeight = 0.0
    }
    
    override func drawContentForPageAtIndex(pageIndex: Int, inRect contentRect: CGRect) {
        // Square
        let imagesHeight = POINTS_PER_INCH
        let imagesWidth = POINTS_PER_INCH
        let imagesRect = CGRectMake(paperRect.origin.x + POINTS_PER_INCH, paperRect.origin.y + POINTS_PER_INCH, CGRectGetMaxX(paperRect) - POINTS_PER_INCH, CGRectGetMaxY(paperRect) - POINTS_PER_INCH)
        let imageSize = CGSizeMake(imagesWidth, imagesHeight)
    }
    
    func drawImages(images:[UIImage], inRect sourceRect:CGRect, imageSize: CGSize) {
        // 1/4" spacing
        let imagePadding = UIEdgeInsets(top: POINTS_PER_INCH/8, left: POINTS_PER_INCH/4, bottom: POINTS_PER_INCH/16, right: POINTS_PER_INCH/4)
        
        for image in images {
            let imageR = CGRectMake(0, 0, imageSize.width, imageSize.height)
            let sizedRect = AVMakeRectWithAspectRatioInsideRect(image.size, imageR)
            
            image.drawInRect(sizedRect)
            
            let font = UIFont(name: "HelveticaNeue", size: 12)
            var stringAttrib = [NSObject:AnyObject]()
            stringAttrib["NSFontAttributeName"] = font
            
            let lineOne = "Hi"
            //let lineOnePointX = CGRectGetMidX(printableRect) - lineOne.size
        }
    }
}
