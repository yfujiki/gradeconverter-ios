//
//  InfoViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 7/26/15.
//  Copyright © 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import Firebase

protocol InfoViewControllerDelegate: class {
    func composeEmail()
}

class InfoViewController: UIViewController {

    weak var delegate: InfoViewControllerDelegate?

    @IBOutlet var labels: [UILabel]!

    @IBAction func closeButtonTapped(_: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func emailbuttonTapped(_: AnyObject) {
        dismiss(animated: true) {
            self.delegate?.composeEmail()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemID: String(describing: type(of: self)),
            AnalyticsParameterItemName: String(describing: type(of: self)),
        ])

        preferredContentSize = CGSize(width: 280, height: 240)

        if CurrentLang() == .ja {
            preferredContentSize = CGSize(width: 280, height: 260)
        }

        configureColors()
    }

    private func configureColors() {
        for label in labels {
            label.textColor = .mainForegroundColor()
        }
        view.backgroundColor = .myLightGrayColor()
    }
}
