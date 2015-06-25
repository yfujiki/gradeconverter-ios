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

    private var kCellHeight: CGFloat = 96

    private let allGradeSystems = GradeSystemTable().gradeSystems()
    private var gradeSystems = [GradeSystem]()
    private var observers = [NSObjectProtocol]()

    private func updateGradeSystems() {
        gradeSystems = allGradeSystems.filter { (gradeSystem: GradeSystem) -> Bool in
            return !contains(NSUserDefaults.standardUserDefaults().selectedGradeSystems(), gradeSystem)
        }
    }

    deinit {
        for observer in observers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateGradeSystems()

        tableView.registerNib(UINib(nibName: "EditTableViewCell", bundle: nil), forCellReuseIdentifier: "EditTableViewCell")

        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(kNSUserDefaultsSystemSelectionChangedNotification, object: nil, queue: nil) { [weak self] _ in
            self?.updateGradeSystems()
        })
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

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.endUpdates()

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
