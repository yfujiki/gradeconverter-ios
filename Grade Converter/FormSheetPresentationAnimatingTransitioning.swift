//
//  FormSheetPresentationAnimatingTransitioning.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 7/26/15.
//  Copyright © 2015 Responsive Bytes. All rights reserved.
//

import UIKit

@objc class FormSheetPresentationAnimatingTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    var presenting: Bool = false

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let fromView = fromViewController?.view

        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let toView = toViewController?.view

        if presenting {
            if let toView = toView,
               let containerView = transitionContext.containerView(),
               let toViewController = toViewController {
                    let containerViewSize = containerView.frame.size
                    let toViewSize = toViewController.preferredContentSize
                    let offsetX = (containerViewSize.width - toViewSize.width) / 2
                    let offsetY = (containerViewSize.height - toViewSize.height) / 2
                    toView.frame = CGRectMake(offsetX, containerViewSize.height + offsetY, toViewSize.width, toViewSize.height)
                    toView.layer.cornerRadius = 6
                    containerView.addSubview(toView)

                    UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: [], animations: { () -> Void in
                        toView.frame = CGRectOffset(toView.frame, 0, -containerViewSize.height)
                        }, completion: { (success:Bool) -> Void in
                            transitionContext.completeTransition(true)
                    })
            }
        } else {
            if let fromView = fromView,
               let containerView = transitionContext.containerView(),
               let fromViewController = fromViewController {
                    let fromViewSize = fromViewController.preferredContentSize
                    let containerViewSize = containerView.frame.size
                    let offsetX = (containerViewSize.width - fromViewSize.width) / 2
                    let offsetY = (containerViewSize.height - fromViewSize.height) / 2

                    fromView.frame = CGRectMake(offsetX, offsetY, fromViewSize.width, fromViewSize.height)

                    UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: [], animations: { () -> Void in
                        fromView.frame = CGRectOffset(fromView.frame, 0, containerViewSize.height)
                        }, completion: { (success: Bool) -> Void in
                            fromView.removeFromSuperview()
                            transitionContext.completeTransition(true)
                    })
            }
        }
    }
}
