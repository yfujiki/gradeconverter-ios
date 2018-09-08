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
            guard let currentFont = font, currentFont.fontName.range(of: "Medium") == nil else {
                return
            }

            font = UIFont(name: newValue, size: font.pointSize)
        }
    }

    var substituteBoldFontName: String {
        get {
            return font.fontName
        }
        set {
            // If the font is bold, set this font
            guard let currentFont = font, currentFont.fontName.range(of: "Medium") != nil else {
                return
            }

            font = UIFont(name: newValue, size: font.pointSize)
        }
    }
}
