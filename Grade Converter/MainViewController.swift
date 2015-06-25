//
//  MainViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var tableView: UITableView!

    private var selectedSystems: [GradeSystem] = NSUserDefaults.standardUserDefaults().selectedGradeSystems()

    private var kMinimumCellHeight: CGFloat = 128
    private var kMaximumCellHeight: CGFloat = 128

    override func viewDidLoad() {
        super.viewDidLoad()

        kMaximumCellHeight = CGRectGetHeight(tableView.frame) / 3

        tableView.registerNib(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSystems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MainTableViewCell") as! MainTableViewCell

        cell.gradeSystem = selectedSystems[indexPath.row]
        cell.indexes = NSUserDefaults.standardUserDefaults().currentIndexes()

        return cell
    }

    // MARK:- UITableViewDelegate
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kMinimumCellHeight
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let count = selectedSystems.count + 1
        var targetHeight = CGRectGetHeight(tableView.frame) / CGFloat(count)
        targetHeight = min(targetHeight, kMaximumCellHeight)
        targetHeight = max(targetHeight, kMinimumCellHeight)

        return targetHeight
    }
}

