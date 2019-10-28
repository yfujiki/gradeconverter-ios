//
//  UIColor+Additions.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/25/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

extension UIColor {

    class func myLightAquaColor() -> UIColor {
        return UIColor(red: 168.0 / 255, green: 224.0 / 255, blue: 254.0 / 255, alpha: 1.0)
    }

    class func myAquaColor() -> UIColor {
        //        return UIColor(red: 80.0/255, green: 148.0/255, blue: 227.0/255, alpha: 1.0)
        return UIColor(red: 0.0 / 255, green: 152.0 / 255, blue: 255.0 / 255, alpha: 1.0)
    }

    class func systemLightGrayColor() -> UIColor {
        return UIColor(red: 242.0 / 255, green: 242.0 / 255, blue: 242.0 / 255, alpha: 1.0)
    }

    class func mainBackgroundColors() -> [UIColor] {
        return [UIColor.white, UIColor.white]
    }

    class func mainForegroundColor() -> UIColor {
        return UIColor(red: 64.0 / 255, green: 64.0 / 255, blue: 64.0 / 255, alpha: 1.0)
    }

    class func addColor() -> UIColor {
        return systemLightGrayColor()
    }
}
