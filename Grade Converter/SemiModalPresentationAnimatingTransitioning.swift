//
//  PresentationAnimatingTransitioning.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/28/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

@objc class SemiModalPresentationAnimatingTransitioning: PresentationAnimatingTransitioning {

    override func toViewFrameFromToViewController(toViewController: UIViewController, containerView: UIView) -> CGRect {
        return CGRectMake(20, 20, containerView.frame.width - 40, containerView.frame.height - 20)
    }

    override func fromViewFrameFromFromViewController(fromViewController: UIViewController, containerView: UIView) -> CGRect {
        return CGRectMake(20, 20, containerView.frame.width - 40, containerView.frame.height - 20)
    }
}
