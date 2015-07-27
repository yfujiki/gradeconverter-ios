//
//  PresentationAnimatingTransitioning.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/28/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

@objc class SemiModalPresentationAnimatingTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

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
               let containerView = transitionContext.containerView() {
                toView.frame = CGRectOffset(CGRectInset(containerView.frame, 20, 20), 0, 20)
                toView.frame = CGRectOffset(toView.frame, 0, toView.frame.height)
                containerView.addSubview(toView)

                UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: [], animations: { () -> Void in
                    toView.frame = CGRectOffset(toView.frame, 0, -toView.frame.height)
                }, completion: { (success:Bool) -> Void in
                    transitionContext.completeTransition(true)
                })
            }
        } else {
            if let fromView = fromView,
               let containerView = transitionContext.containerView() {
                fromView.frame = CGRectOffset(CGRectInset(containerView.frame, 20, 20), 0, 20)

                UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: [], animations: { () -> Void in
                    fromView.frame = CGRectOffset(fromView.frame, 0, fromView.frame.height)
                }, completion: { (success: Bool) -> Void in
                    fromView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                })
            }
        }
    }
}
