//
//  EditViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    @IBAction func doneButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private let allGradeSystems = GradeSystemTable().gradeSystems()

    private var gradeSystems: [GradeSystem] = []

    private var kCellHeight: CGFloat = 128

    private func updateGradeSystems() {
        gradeSystems = allGradeSystems.filter { (gradeSystem: GradeSystem) -> Bool in
            return !contains(NSUserDefaults.standardUserDefaults().selectedGradeSystems(), gradeSystem)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateGradeSystems()

        tableView.registerNib(UINib(nibName: "EditTableViewCell", bundle: nil), forCellReuseIdentifier: "EditTableViewCell")
    }

    // MARK:- UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeSystems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("EditTableViewCell") as! EditTableViewCell

        cell.gradeSystem = gradeSystems[indexPath.row]

        return cell
    }

    // MARK:- UITableViewDelegate
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kCellHeight
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kCellHeight
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let gradeSystem = gradeSystems[indexPath.row]
        NSUserDefaults.standardUserDefaults().addSelectedGradeSystem(gradeSystem)
        updateGradeSystems()

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        tableView.reloadData()
    }
}
