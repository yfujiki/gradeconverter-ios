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

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func toViewFrameFromToViewController(toViewController _: UIViewController, containerView _: UIView) -> CGRect {
        // Override in subclass
        assert(false, "This method needs to be overridden in subclass.")
        return CGRect.zero
    }

    func fromViewFrameFromFromViewController(fromViewController _: UIViewController, containerView _: UIView) -> CGRect {
        // Override in subclass
        assert(false, "This method needs to be overridden in subclass.")
        return CGRect.zero
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let fromView = fromViewController?.view

        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let toView = toViewController?.view

        if presenting {
            let containerView = transitionContext.containerView
            if let toView = toView,
                let toViewController = toViewController {
                let toViewFrame = toViewFrameFromToViewController(toViewController: toViewController, containerView: containerView)
                toView.frame = toViewFrame.offsetBy(dx: 0, dy: containerView.frame.size.height - toView.frame.origin.y)
                containerView.addSubview(toView)

                UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: [], animations: { () in
                    toView.frame = toViewFrame
                }, completion: { (_: Bool) in
                    transitionContext.completeTransition(true)
                })
            }
        } else {
            let containerView = transitionContext.containerView
            if let fromView = fromView,
                let fromViewController = fromViewController {
                fromView.frame = fromViewFrameFromFromViewController(fromViewController: fromViewController, containerView: containerView)

                UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: [], animations: { () in
                    fromView.frame = (fromView.frame).offsetBy(dx: 0, dy: containerView.frame.size.height - fromView.frame.origin.y)
                }, completion: { (_: Bool) in
                    fromView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                })
            }
        }
    }
}
