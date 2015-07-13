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

    class func myAquaColor() -> UIColor {
        return UIColor(red: 48.0/255, green: 172.0/255, blue: 255.0/255, alpha: 1.0)
    }

    class func myBlueColor() -> UIColor {
        return UIColor(red: 205.0/255, green: 215.0/255, blue: 255.0/255, alpha: 1.0)
    }

    class func myDarkBlueColor() -> UIColor {
        return UIColor(red: 0.0/255, green: 38.0/255, blue: 255.0/255, alpha: 1.0)
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

    class func systemLightGrayColor() -> UIColor {
        return UIColor(red: 242.0/255, green: 242.0/255, blue: 242.0/255, alpha: 1.0)
    }

    class func color1() -> UIColor {
        return UIColor(red: 192.0/255, green: 250.0/255, blue: 178.0/255, alpha: 1.0)
    }

    class func color2() -> UIColor {
        return UIColor(red: 194.0/255, green: 248.0/255, blue: 191.0/255, alpha: 1.0)
    }

    class func color3() -> UIColor {
        return UIColor(red: 196.0/255, green: 246.0/255, blue: 205.0/255, alpha: 1.0)
    }

    class func color4() -> UIColor {
        return UIColor(red: 198.0/255, green: 244.0/255, blue: 219.0/255, alpha: 1.0)
    }

    class func color5() -> UIColor {
        return UIColor(red: 200.0/255, green: 242.0/255, blue: 233.0/255, alpha: 1.0)
    }

    class func color6() -> UIColor {
        return UIColor(red: 202.0/255, green: 240.0/255, blue: 247.0/255, alpha: 1.0)
    }

    class func myColors() -> [UIColor] {
        return [color1(), color3()]
    }

    class func addColor() -> UIColor {
        return systemLightGrayColor()
    }
}