//
//  UIColor+Additions.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/25/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

extension UIColor {

    class func myOrangeColor() -> UIColor {
        return UIColor(red: 255.0/255, green: 225.0/255, blue: 179.0/255, alpha: 1.0)
    }

    class func myYellowColor() -> UIColor {
        return UIColor(red: 250.0/255, green: 250.0/255, blue: 201.0/255, alpha: 1.0)
    }

    class func myGreenColor() -> UIColor {
        return UIColor(red: 192.0/255, green: 250.0/255, blue: 178.0/255, alpha: 1.0)
    }

    class func myWaterColor() -> UIColor {
        return UIColor(red: 202.0/255, green: 238.0/255, blue: 247.0/255, alpha: 1.0)
    }

    class func myBlueColor() -> UIColor {
        return UIColor(red: 205.0/255, green: 215.0/255, blue: 255.0/255, alpha: 1.0)
    }

    class func myPurpleColor() -> UIColor {
        return UIColor(red: 240.0/255, green: 217.0/255, blue: 255.0/255, alpha: 1.0)
    }

    class func myRedColor() -> UIColor {
        return UIColor(red: 255.0/255, green: 187.0/255, blue: 178.0/255, alpha: 1.0)
    }

    class func myDarkRedColor() -> UIColor {
        return UIColor(red: 255.0/255, green: 38.0/255, blue: 0.0/255, alpha: 1.0)
    }

    class func myColors() -> [UIColor] {
        return [myOrangeColor(), myYellowColor(), myGreenColor(), myWaterColor(), myBlueColor(), myPurpleColor()]
    }

    class func addColor() -> UIColor {
        return myRedColor()
    }
}