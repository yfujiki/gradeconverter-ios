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

    lazy private var dimmingView: UIView = { [unowned self] _ in
        var view = UIView()
        view.backgroundColor = UIColor.blackColor()

        if let containerView = self.containerView {
            view.frame = containerView.bounds
        }

        return view
    }()

    override func presentationTransitionWillBegin() {
        let coordinator = presentedViewController.transitionCoordinator()
        dimmingView.alpha = 0.0

        if let containerView = containerView {
            containerView.addSubview(dimmingView)
        }
        
        coordinator?.animateAlongsideTransition({ [weak self] (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self?.dimmingView.alpha = kDimmingViewAlpha
        }, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
        })
    }

    override func dismissalTransitionWillBegin() {
        if let mainNavigationController = presentingViewController as? UINavigationController,
            let mainViewController = mainNavigationController.childViewControllers.first as? MainViewController {
                mainViewController.reloadTableView()
        }

        let coordinator = presentingViewController.transitionCoordinator()
        dimmingView.alpha = kDimmingViewAlpha
        coordinator?.animateAlongsideTransition({ [weak self] (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self?.dimmingView.alpha = 0.0
        }, completion: { [weak self] (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self?.dimmingView.removeFromSuperview()
        })
    }
}
