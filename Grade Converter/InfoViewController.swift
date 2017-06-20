//
//  InfoViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 7/26/15.
//  Copyright © 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func emailbuttonTapped(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kEmailComposingNotification), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: 280, height: 240)

        if CurrentLang() == .ja {
            preferredContentSize = CGSize(width: 280, height: 260)
        }
    }
}
