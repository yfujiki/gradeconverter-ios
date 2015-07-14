//
//  EditViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, EditTableViewCellDelegate {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private var kCellHeight: CGFloat = 96

    private let allGradeSystems = GradeSystemTable.sharedInstance.gradeSystems()
    private var gradeSystems = [GradeSystem]()
    private var observers = [NSObjectProtocol]()

    lazy private var blurEffectView: UIVisualEffectView = { [unowned self] _ in
        let effect = UIBlurEffect(style: .Light)
        var effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.view.bounds

        return effectView
    }()

    private func updateGradeSystems() {
        gradeSystems = allGradeSystems.filter { (gradeSystem: GradeSystem) -> Bool in
            return !NSUserDefaults.standardUserDefaults().selectedGradeSystems().contains(gradeSystem)
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

        imageView.addSubview(blurEffectView)
        setConstraintsForBlurEffectView()

        tableView.tableFooterView = UIView()
    }

    private func setConstraintsForBlurEffectView() {
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["imageView": imageView, "blurEffectView": blurEffectView]
        imageView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurEffectView]|", options: .AlignAllCenterX, metrics: nil, views: views))
        imageView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurEffectView]|", options: .AlignAllCenterY, metrics: nil, views: views))
    }

    // MARK:- UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeSystems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditTableViewCell") as! EditTableViewCell
        cell.delegate = self
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
        addGradeFromIndexPath(indexPath)

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK:- EditTableViewCellDelegate

    func didAddGradeCell(cell: EditTableViewCell) {
        if let selectedIndexPath = tableView.indexPathForCell(cell) {
            addGradeFromIndexPath(selectedIndexPath)
        }
    }

    private func addGradeFromIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let gradeSystem = gradeSystems[indexPath.row]
        NSUserDefaults.standardUserDefaults().addSelectedGradeSystem(gradeSystem)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        tableView.endUpdates()
    }
}
