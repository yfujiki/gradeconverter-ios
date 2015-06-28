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
    @IBOutlet weak var imageView: UIImageView!

    private var selectedSystems: [GradeSystem] = []

    private var kMinimumCellHeight: CGFloat = 96
    private var kMaximumCellHeight: CGFloat = 96

    private var observers = [NSObjectProtocol]()

    lazy private var blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .Light)
        var effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.view.bounds

        return effectView
    }()

    private func updateSelectedSystems() {
        selectedSystems = NSUserDefaults.standardUserDefaults().selectedGradeSystems()

        editButtonItem().enabled = selectedSystems.count > 0
        if selectedSystems.count == 0 {
            self.editing = false
        }
    }

    deinit {
        for observer in observers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }

    private func setEditingBody(editing: Bool) {
        if tableView.editing != editing  {
            tableView.editing = editing
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.selectedSystems.count, inSection: 0)], withRowAnimation: .Automatic)
            })
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if animated {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.setEditingBody(editing)
            })
        } else {
            setEditingBody(editing)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = self.editButtonItem()

        updateSelectedSystems()

        kMaximumCellHeight = CGRectGetHeight(tableView.frame) / 3

        tableView.registerNib(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        tableView.registerNib(UINib(nibName: "AddTableViewCell", bundle: nil), forCellReuseIdentifier: "AddTableViewCell")

        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(kNSUserDefaultsSystemSelectionChangedNotification, object: nil, queue: nil) { [weak self] _ in
            self?.updateSelectedSystems()
        })

        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(kGradeSelectedNotification, object: nil, queue: nil, usingBlock: { [weak self] (notification: NSNotification!) -> Void in
            if let indexes = notification.userInfo?[kNewIndexesKey] as? [Int] {
                if NSUserDefaults.standardUserDefaults().currentIndexes() != indexes {
                    NSUserDefaults.standardUserDefaults().setCurrentIndexes(indexes)

                    var indexPaths = [NSIndexPath]()

                    if let strongSelf = self {
                        for cell in strongSelf.tableView.visibleCells() {
                            if let targetCell = cell as? MainTableViewCell,
                               let baseCell = notification.object as? MainTableViewCell where targetCell != baseCell,
                               let targetIndexPath = strongSelf.tableView.indexPathForCell(targetCell) {
                                indexPaths.append(targetIndexPath)
                            }
                        }
                        strongSelf.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                    }
                }
            }
        }))

        imageView.addSubview(blurEffectView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSystems.count + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < selectedSystems.count {
            var cell = tableView.dequeueReusableCellWithIdentifier("MainTableViewCell") as! MainTableViewCell
            cell.backgroundColor = UIColor.clearColor()

            cell.gradeSystem = selectedSystems[indexPath.row]
            cell.indexes = NSUserDefaults.standardUserDefaults().currentIndexes()

            let colors = UIColor.myColors()
            cell.cardColor = colors[indexPath.row % colors.count]

            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("AddTableViewCell") as! AddTableViewCell
            cell.backgroundColor = UIColor.clearColor()
            cell.hidden = editing

            return cell
        }
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

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.tag = indexPath.row
        
        if let mainTableViewCell = cell as? MainTableViewCell {
            mainTableViewCell.configureGradeLabels()
            mainTableViewCell.configureInitialContentOffset()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == selectedSystems.count {
            performSegueWithIdentifier("PresentEdit", sender: self)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView.editing && indexPath.row != selectedSystems.count
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView.editing && indexPath.row != selectedSystems.count
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row

        if destinationIndex != selectedSystems.count {
            let item = selectedSystems.removeAtIndex(sourceIndex)
            selectedSystems.insert(item, atIndex: destinationIndex)
        }
    }

    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {

        if proposedDestinationIndexPath.row == selectedSystems.count {
            return NSIndexPath(forRow: selectedSystems.count - 1, inSection: 0)
        }

        return proposedDestinationIndexPath
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let systemToDelete = selectedSystems[indexPath.row]
            NSUserDefaults.standardUserDefaults().removeSelectedGradeSystem(systemToDelete)

            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
}

