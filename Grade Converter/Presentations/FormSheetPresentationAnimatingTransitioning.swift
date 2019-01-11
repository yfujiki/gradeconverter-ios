//
//  FormSheetPresentationAnimatingTransitioning.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 7/26/15.
//  Copyright © 2015 Responsive Bytes. All rights reserved.
//

import UIKit

@objc class FormSheetPresentationAnimatingTransitioning: PresentationAnimatingTransitioning {

    override func toViewFrameFromToViewController(toViewController: UIViewController, containerView: UIView) -> CGRect {
        let containerViewSize = containerView.frame.size
        let toViewSize = toViewController.preferredContentSize
        let offsetX = (containerViewSize.width - toViewSize.width) / 2
        let offsetY = (containerViewSize.height - toViewSize.height) / 2

        return CGRect(x: offsetX, y: offsetY, width: toViewSize.width, height: toViewSize.height)
    }

    override func fromViewFrameFromFromViewController(fromViewController: UIViewController, containerView: UIView) -> CGRect {
        let fromViewSize = fromViewController.preferredContentSize
        let containerViewSize = containerView.frame.size
        let offsetX = (containerViewSize.width - fromViewSize.width) / 2
        let offsetY = (containerViewSize.height - fromViewSize.height) / 2

        return CGRect(x: offsetX, y: offsetY, width: fromViewSize.width, height: fromViewSize.height)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        if presenting {
            if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let toView = toViewController.view {
                toView.layer.cornerRadius = 6
            }
        }
    }
}
