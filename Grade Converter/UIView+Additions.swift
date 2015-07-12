//
//  UIView.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/30/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

extension UIView {
    func snapshot() -> UIImageView {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let imageView = UIImageView(image: image)
        imageView.layer.shadowRadius = 5
        imageView.layer.shadowOpacity = 0.4
//        imageView.layer.shadowOffset = CGSizeMake(-5, 0)

        return imageView
    }
}
