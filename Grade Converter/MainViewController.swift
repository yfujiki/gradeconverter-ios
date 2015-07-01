//
//  MainViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!

    private var selectedSystems: [GradeSystem] = []

    private var kMinimumCellHeight: CGFloat = 96
    private var kMaximumCellHeight: CGFloat = 96

    private let kAnimationRotateDeg = CGFloat(1.0) * CGFloat(M_PI) / CGFloat(180.0)

    private var observers = [NSObjectProtocol]()

    lazy private var blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .Light)
        var effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.view.bounds

        return effectView
    }()

    private func updateSelectedSystems() {
        selectedSystems = NSUserDefaults.standardUserDefaults().selectedGradeSystems()

        navigationItem.rightBarButtonItem = editButtonItem()

        if selectedSystems.count == 0 {
            self.editing = false
        }
    }

    deinit {
        for observer in observers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.reloadData()
    }

    private func startJigglingCell(cell: UITableViewCell) {
        let leftWobble = CGAffineTransformMakeRotation(-kAnimationRotateDeg)
        let rightWobble = CGAffineTransformMakeRotation(kAnimationRotateDeg)

        cell.transform = leftWobble

        UIView.animateWithDuration(0.1, delay: 0, options: (.Autoreverse | .AllowUserInteraction | .Repeat), animations: { [weak self] () -> Void in
            UIView.setAnimationRepeatCount(Float(NSNotFound))
            cell.transform = rightWobble
            return
            }, completion: { (success: Bool) -> Void in
        })
    }

    private func stopJigglingCell(cell: UITableViewCell) {
        cell.layer.removeAllAnimations()
        cell.transform = CGAffineTransformIdentity
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

    // MARK:- Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentEdit" {
            if let destinationViewController = segue.destinationViewController as? UIViewController {
                destinationViewController.transitioningDelegate = self
                destinationViewController.modalPresentationStyle = .Custom
            }
        }
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
        if indexPath.row < selectedSystems.count {
            var totalHeight = CGRectGetHeight(tableView.frame) - AddTableViewCell.kCellHeight
            let count = selectedSystems.count
            var targetHeight = totalHeight / CGFloat(count)
            targetHeight = min(targetHeight, kMaximumCellHeight)
            targetHeight = max(targetHeight, kMinimumCellHeight)

            return targetHeight
        } else {
            return AddTableViewCell.kCellHeight
        }
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.tag = indexPath.row
        
        if let mainTableViewCell = cell as? MainTableViewCell {
            mainTableViewCell.configureGradeLabels()
            mainTableViewCell.configureInitialContentOffset()

            if editing {
                startJigglingCell(mainTableViewCell)
            } else {
                stopJigglingCell(mainTableViewCell)
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == selectedSystems.count {
            performSegueWithIdentifier("PresentEdit", sender: self)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
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

    func reloadTableView() {
        tableView.reloadData()
    }
    
    // MARK:- UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = PresentationAnimatingTransitioning()
        transitioning.presenting = true

        return transitioning
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = PresentationAnimatingTransitioning()
        transitioning.presenting = false

        return transitioning
    }

    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

