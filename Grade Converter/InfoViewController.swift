//
//  InfoViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 7/26/15.
//  Copyright © 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBAction func closeButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func emailbuttonTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(kEmailComposingNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSizeMake(280, 300)

        if CurrentLang() == .ja {
            preferredContentSize = CGSizeMake(280, 260)
        }
    }
}
