//
//  PresentationController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/29/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {
    private let kDimmingViewAlpha = CGFloat(0.7)

    lazy private var dimmingView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.blackColor()
        view.frame = self.containerView.bounds

        return view
    }()

    override func presentationTransitionWillBegin() {
        let coordinator = presentedViewController.transitionCoordinator()

        dimmingView.alpha = 0.0
        containerView.addSubview(dimmingView)
        NSLog("dimmingView \(dimmingView)")
        NSLog("containerView \(containerView)")
        coordinator?.animateAlongsideTransition({ [weak self] (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self?.dimmingView.alpha = kDimmingViewAlpha
        }, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
        })
    }

    override func dismissalTransitionWillBegin() {
        let coordinator = presentingViewController.transitionCoordinator()

        dimmingView.alpha = kDimmingViewAlpha

        coordinator?.animateAlongsideTransition({ [weak self] (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self?.dimmingView.alpha = 0.0
        }, completion: { [weak self] (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self?.dimmingView.removeFromSuperview()
        })
    }
}
