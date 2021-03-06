//
//  PresentationController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/29/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {
    fileprivate let kDimmingViewAlpha = CGFloat(0.7)

    fileprivate lazy var dimmingView: UIView = { // [unowned self] _ in
        var view = UIView()
        view.backgroundColor = UIColor.black

        if let containerView = self.containerView {
            view.frame = containerView.bounds
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PresentationController.dismissPresentedViewController(_:))))

        return view
    }()

    override func presentationTransitionWillBegin() {
        let coordinator = presentedViewController.transitionCoordinator
        dimmingView.alpha = 0.0

        if let containerView = containerView {
            containerView.addSubview(dimmingView)
            setConstraintsForDimmingViewInContainerView(containerView)
        }

        coordinator?.animate(alongsideTransition: { [weak self] (_: UIViewControllerTransitionCoordinatorContext!) in
            if let strongSelf = self {
                strongSelf.dimmingView.alpha = strongSelf.kDimmingViewAlpha
            }
        }, completion: { (_: UIViewControllerTransitionCoordinatorContext!) in
        })
    }

    override func dismissalTransitionWillBegin() {
        if let mainNavigationController = presentingViewController as? UINavigationController,
            let mainViewController = mainNavigationController.children.first as? MainViewController {
            mainViewController.reloadTableView()
        }

        let coordinator = presentingViewController.transitionCoordinator
        dimmingView.alpha = kDimmingViewAlpha
        coordinator?.animate(alongsideTransition: { [weak self] (_: UIViewControllerTransitionCoordinatorContext!) in
            self?.dimmingView.alpha = 0.0
        }, completion: { [weak self] (_: UIViewControllerTransitionCoordinatorContext!) in
            self?.dimmingView.removeFromSuperview()
        })
    }

    fileprivate func setConstraintsForDimmingViewInContainerView(_ containerView: UIView) {
        dimmingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }

    @objc func dismissPresentedViewController(_: AnyObject) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
