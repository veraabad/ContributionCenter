//
//  QRGenerator.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/6/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class QRGenerator {
    
    // This is where generated QR code will be stored
    var qrImage:UIImage!
    
    init(qrString: String, sizeRate: CGFloat) {
        
        // Generate QR image from CIFilter
        var filter:CIFilter! = CIFilter(name: "CIQRCodeGenerator")
        filter.setDefaults()
        
        // Pass string to CIFilter
        var data:NSData! = qrString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        
        // Obtain QR image from CIFilter
        var outputImg:CIImage! = filter.outputImage
        
        // Create context in order to generate QR code
        var context = CIContext(options: [kCIContextUseSoftwareRenderer: true])
        var cgimg:CGImageRef! = context.createCGImage(outputImg, fromRect: outputImg.extent())
        
        var img:UIImage! = UIImage(CGImage: cgimg, scale: 1.0, orientation: UIImageOrientation.Up)
        
        var width:CGFloat! = img.size.width * sizeRate
        var height:CGFloat! = img.size.height * sizeRate
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        var cgContext:CGContextRef! = UIGraphicsGetCurrentContext()
        
        CGContextSetInterpolationQuality(cgContext, kCGInterpolationNone)
        img.drawInRect(CGRectMake(0, 0, width, height))
        img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        qrImage = img
    }
}
