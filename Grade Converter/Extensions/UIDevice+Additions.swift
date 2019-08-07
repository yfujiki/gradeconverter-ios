//
//  UIDevice+Additions.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 7/9/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import UIKit

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
