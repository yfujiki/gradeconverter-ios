//
//  MainViewController+InfoViewControllerDelegate.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/16/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation
import MessageUI

extension MainViewController: InfoViewControllerDelegate {
    func composeEmail() {
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController()
            composeViewController.mailComposeDelegate = self
            composeViewController.setToRecipients([kSupportEmailAddress])
            composeViewController.setSubject(kSupportEmailSubject)
            composeViewController.navigationBar.tintColor = UIColor.white

            // This is not working in iOS12 due to bug :
            // https://stackoverflow.com/questions/52522308/change-title-color-of-navigation-bar-in-mfmailcomposeviewcontroller-in-ios-12-no
            composeViewController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
            ]
            present(composeViewController, animated: true, completion: nil)
        }
    }
}

extension MFMailComposeViewController {
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // This may be just a hack. Without this, the status bar on ComposeViewController stays black
        setNeedsStatusBarAppearanceUpdate()
    }
}
