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
            composeViewController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
            ]
            present(composeViewController, animated: true, completion: nil)
        }
    }
}
