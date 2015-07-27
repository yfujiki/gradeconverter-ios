//
//  PresentationAnimatingTransitioning.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 7/27/15.
//  Copyright © 2015 Responsive Bytes. All rights reserved.
//

import UIKit

@objc class PresentationAnimatingTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    var presenting: Bool = false

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

    func toViewFrameFromToViewController(toViewController: UIViewController, containerView: UIView) -> CGRect {
        // Override in subclass
        assert(false, "This method needs to be overridden in subclass.")
        return CGRectZero
    }

    func fromViewFrameFromFromViewController(fromViewController: UIViewController, containerView: UIView) -> CGRect {
        // Override in subclass
        assert(false, "This method needs to be overridden in subclass.")
        return CGRectZero
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
                    let toViewFrame = toViewFrameFromToViewController(toViewController, containerView: containerView)
                    toView.frame = CGRectOffset(toViewFrame, 0, containerView.frame.size.height - toView.frame.origin.y)
                    containerView.addSubview(toView)

                    UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: [], animations: { () -> Void in
                        toView.frame = toViewFrame
                        }, completion: { (success:Bool) -> Void in
                            transitionContext.completeTransition(true)
                    })
            }
        } else {
            if let fromView = fromView,
               let containerView = transitionContext.containerView(),
               let fromViewController = fromViewController {
                fromView.frame = fromViewFrameFromFromViewController(fromViewController, containerView: containerView)

                UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: [], animations: { () -> Void in
                    fromView.frame = CGRectOffset(fromView.frame, 0, containerView.frame.size.height - fromView.frame.origin.y)
                    }, completion: { (success: Bool) -> Void in
                        fromView.removeFromSuperview()
                        transitionContext.completeTransition(true)
                })
            }
        }
    }

}