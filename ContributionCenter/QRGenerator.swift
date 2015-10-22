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
        let filter:CIFilter! = CIFilter(name: "CIQRCodeGenerator")
        filter.setDefaults()
        
        // Pass string to CIFilter
        let data:NSData! = qrString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        
        // Obtain QR image from CIFilter
        let outputImg:CIImage! = filter.outputImage
        
        // Create context in order to generate QR code
        let context = CIContext(options: [kCIContextUseSoftwareRenderer: true])
        let cgimg:CGImageRef! = context.createCGImage(outputImg, fromRect: outputImg.extent)
        
        var img:UIImage! = UIImage(CGImage: cgimg, scale: 0.5, orientation: UIImageOrientation.Up)
        
        let width:CGFloat! = img.size.width * sizeRate
        let height:CGFloat! = img.size.height * sizeRate
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        let cgContext:CGContextRef! = UIGraphicsGetCurrentContext()
        
        CGContextSetInterpolationQuality(cgContext, CGInterpolationQuality.None)
        img.drawInRect(CGRectMake(0, 0, width, height))
        img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        qrImage = img
    }
}
