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

        return CGRectMake(offsetX, offsetY, toViewSize.width, toViewSize.height)
    }

    override func fromViewFrameFromFromViewController(fromViewController: UIViewController, containerView: UIView) -> CGRect {
        let fromViewSize = fromViewController.preferredContentSize
        let containerViewSize = containerView.frame.size
        let offsetX = (containerViewSize.width - fromViewSize.width) / 2
        let offsetY = (containerViewSize.height - fromViewSize.height) / 2

        return CGRectMake(offsetX, offsetY, fromViewSize.width, fromViewSize.height)
    }

    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(transitionContext)

        if presenting {
            if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
               let toView = toViewController.view {
                toView.layer.cornerRadius = 6
            }
        }
    }
}
