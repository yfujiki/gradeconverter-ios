//
//  UILabel+Additions.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 7/25/15.
//  Copyright © 2015 Responsive Bytes. All rights reserved.
//

import UIKit

extension UILabel {
    var substituteFontName: String {
        get {
            return font.fontName
        }
        set {
            // If the font is not bold, set this font
            if font.fontName.range(of: "Medium") == nil {
                font = UIFont(name: newValue, size: font.pointSize)
            }
        }
    }

    var substituteBoldFontName: String {
        get {
            return font.fontName
        }
        set {
            // If the font is bold, set this font
            if font.fontName.range(of: "Medium") != nil {
                font = UIFont(name: newValue, size: font.pointSize)
            }
        }
    }
}
