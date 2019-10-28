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
        return UIColor(red: 0.0 / 255, green: 152.0 / 255, blue: 255.0 / 255, alpha: 1.0)
    }

    class func myLightGrayColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 32.0 / 255, green: 32.0 / 255, blue: 32.0 / 255, alpha: 1.0)

                } else {
                    return UIColor(red: 242.0 / 255, green: 242.0 / 255, blue: 242.0 / 255, alpha: 1.0)
                }
            }
        } else {
            return UIColor(red: 242.0 / 255, green: 242.0 / 255, blue: 242.0 / 255, alpha: 1.0)
        }
    }

    class func mainBackgroundColors() -> [UIColor] {
        return [mainBackgroundColor(), mainBackgroundColor()]
    }

    class func mainBackgroundColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return .black
                } else {
                    return .white
                }
            }
        } else {
            return .white
        }
    }

    class func mainForegroundColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return .white
                } else {
                    return UIColor(red: 64.0 / 255, green: 64.0 / 255, blue: 64.0 / 255, alpha: 1.0)
                }
            }
        } else {
            return UIColor(red: 64.0 / 255, green: 64.0 / 255, blue: 64.0 / 255, alpha: 1.0)
        }
    }

    class func addColor() -> UIColor {
        return myLightGrayColor()
    }
}
