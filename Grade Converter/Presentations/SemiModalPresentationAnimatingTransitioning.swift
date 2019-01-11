//
//  PresentationAnimatingTransitioning.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/28/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

@objc class SemiModalPresentationAnimatingTransitioning: PresentationAnimatingTransitioning {

    override func toViewFrameFromToViewController(toViewController _: UIViewController, containerView: UIView) -> CGRect {
        return CGRect(x: 20, y: 40, width: containerView.frame.width - 40, height: containerView.frame.height - 40)
    }

    override func fromViewFrameFromFromViewController(fromViewController _: UIViewController, containerView: UIView) -> CGRect {
        return CGRect(x: 20, y: 40, width: containerView.frame.width - 40, height: containerView.frame.height - 40)
    }
}
