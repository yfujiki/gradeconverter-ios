//
//  MainViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, MainTableViewCellDelegate {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!

    private var selectedSystems: [GradeSystem] = []

    private var kMinimumCellHeight: CGFloat = 96
    private var kMaximumCellHeight: CGFloat = 96

    private var observers = [NSObjectProtocol]()

    lazy private var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        gestureRecognizer.minimumPressDuration = 0.2
        gestureRecognizer.delegate = self

        return gestureRecognizer
    }()

    lazy private var blurEffectView: UIVisualEffectView = { [unowned self] _ in
        let effect = UIBlurEffect(style: .Light)
        var effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.imageView.bounds

        return effectView
    }()

    private func updateSelectedSystems() {
        selectedSystems = NSUserDefaults.standardUserDefaults().selectedGradeSystems()

        navigationItem.rightBarButtonItem?.enabled = selectedSystems.count > 0

        if selectedSystems.count == 0 {
            editing = false
        }
    }

    deinit {
        for observer in observers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if (editing) {
            tableView.addGestureRecognizer(longPressGestureRecognizer)
        } else {
            tableView.removeGestureRecognizer(longPressGestureRecognizer)
        }

        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem()

        updateSelectedSystems()

        kMaximumCellHeight = CGRectGetHeight(tableView.frame) / 3

        tableView.registerNib(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        tableView.registerNib(UINib(nibName: "AddTableViewCell", bundle: nil), forCellReuseIdentifier: "AddTableViewCell")

        registerForNotifications()

        imageView.addSubview(blurEffectView)
        setConstraintsForBlurEffectView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func redrawVisibleRows() {
        if let indexPaths = tableView.indexPathsForVisibleRows {
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        }
    }

    private func setConstraintsForBlurEffectView() {
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["imageView": imageView, "blurEffectView": blurEffectView]
        imageView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurEffectView]|", options: .AlignAllCenterX, metrics: nil, views: views))
        imageView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurEffectView]|", options: .AlignAllCenterY, metrics: nil, views: views))
    }

    // MARK:- Notification handlers
    private func registerForNotifications() {
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(kNSUserDefaultsSystemSelectionChangedNotification, object: nil, queue: nil) { [weak self] _ in
            self?.updateSelectedSystems()
        })

        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(kGradeSelectedNotification, object: nil, queue: nil) { [weak self] (notification: NSNotification!) -> Void in
            if let strongSelf = self {
                if let indexes = notification.userInfo?[kNewIndexesKey] as? [Int] {
                    if NSUserDefaults.standardUserDefaults().currentIndexes() != indexes {
                        NSUserDefaults.standardUserDefaults().setCurrentIndexes(indexes)

                        if let baseCell = notification.object as? MainTableViewCell {
                            let baseIndexPath = strongSelf.tableView.indexPathForCell(baseCell)
                            let baseRow = baseIndexPath == nil ? NSNotFound : baseIndexPath!.row
                            strongSelf.updateBaseSystemToIndex(baseRow)

                            strongSelf.tableView.beginUpdates()
                            strongSelf.reloadVisibleCellsButCell(baseCell, animated: true)
                            strongSelf.reloadOnlyCell(baseCell, animated: false)
                            strongSelf.tableView.endUpdates()
                        }
                    }
                }
            }
        })
    }

    private func updateBaseSystemToIndex(index: Int) {
        for (var i=0; i<selectedSystems.count; i++) {
            selectedSystems[i].isBaseSystem = (i == index)
        }
    }

    private func reloadVisibleCellsButCell(cell: UITableViewCell, animated: Bool) {

        let indexPaths = tableView.visibleCells.reduce([NSIndexPath](), combine: { (var tmp: [NSIndexPath], visibleCell: UITableViewCell) -> [NSIndexPath] in
            if let visibleCell = visibleCell as? MainTableViewCell where visibleCell != cell,
                let visibleIndexPath = tableView.indexPathForCell(visibleCell) {
                    tmp.append(visibleIndexPath)
            }
            return tmp
        })

        let animationOption: UITableViewRowAnimation = animated ? .Automatic : .None
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animationOption)
    }

    private func reloadOnlyCell(cell: UITableViewCell, animated: Bool) {
        if let baseIndexPath = tableView.indexPathForCell(cell) {
            let animationOption: UITableViewRowAnimation = animated ? .Automatic : .None
            tableView.reloadRowsAtIndexPaths([baseIndexPath], withRowAnimation: animationOption)
        }
    }

    // MARK:- Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentEdit" {
            let destinationViewController = segue.destinationViewController
            destinationViewController.transitioningDelegate = self
            destinationViewController.modalPresentationStyle = .Custom
        }
    }

    // MARK:- UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSystems.count + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < selectedSystems.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("MainTableViewCell") as! MainTableViewCell
            cell.delegate = self
            cell.backgroundColor = UIColor.clearColor()

            cell.gradeSystem = selectedSystems[indexPath.row]
            cell.indexes = NSUserDefaults.standardUserDefaults().currentIndexes()

            let colors = UIColor.myColors()
            cell.cardColor = colors[indexPath.row % colors.count]

            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddTableViewCell") as! AddTableViewCell
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
            let totalHeight = CGRectGetHeight(tableView.frame) - AddTableViewCell.kCellHeight
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
            mainTableViewCell.editMode = editing
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

    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presentingViewController: presenting)
    }

    // MARK:- MainTableViewCellDelegate
    func didDeleteCell(cell: MainTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            tableView.beginUpdates()
            let systemToDelete = selectedSystems[indexPath.row]
            NSUserDefaults.standardUserDefaults().removeSelectedGradeSystem(systemToDelete)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            self.tableView.endUpdates()
        }
    }

    // MARK:- UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.locationInView(tableView)

        if location.x >= MainTableViewCell.CardViewLeadingConstraint + MainTableViewCell.DeleteButtonLeadingConstraint &&
            location.x <= MainTableViewCell.CardViewLeadingConstraint + MainTableViewCell.DeleteButtonLeadingConstraint + MainTableViewCell.DeleteButtonWidthConstraint {
                return false
        }

        return true
    }

    // MARK:- Reordering
    var focusIndexPathOfReordering: NSIndexPath?
    var snapShotViewForReordering: UIImageView?
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let state = gestureRecognizer.state

        let location = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(location)

        switch (state) {
        case .Began:
            (focusIndexPathOfReordering, snapShotViewForReordering) = reorderDidBeginAtIndexPath(indexPath)
        case .Changed:
            focusIndexPathOfReordering = replaceCellFromIndexPath(focusIndexPathOfReordering, toIndexPath:indexPath)

            if let snapshotView = snapShotViewForReordering {
                snapShotViewForReordering?.center = CGPointMake(snapshotView.center.x, location.y)
            }
        default:
            cleanupReorderingAction()
        }
    }

    private func reorderDidBeginAtIndexPath(indexPath: NSIndexPath?) -> (NSIndexPath?, UIImageView?){
        if let srcIndexPath = indexPath,
            let srcCell = tableView.cellForRowAtIndexPath(srcIndexPath) as? MainTableViewCell {
            let snapshotView = srcCell.cardViewSnapshot()
            snapshotView.center = srcCell.center
            tableView.addSubview(snapshotView)

            srcCell.hidden = true

            return (srcIndexPath, snapshotView)
        }

        return (nil, nil)
    }

    private func replaceCellFromIndexPath(fromIndexPath: NSIndexPath?, toIndexPath: NSIndexPath?) -> (NSIndexPath?) {
        if let fromIndexPath = fromIndexPath where fromIndexPath.row < selectedSystems.count,
            let toIndexPath = toIndexPath where toIndexPath != fromIndexPath &&  toIndexPath.row < selectedSystems.count {

            let origSystem = selectedSystems[fromIndexPath.row]
            selectedSystems[fromIndexPath.row] = selectedSystems[toIndexPath.row]
            selectedSystems[toIndexPath.row] = origSystem
            tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)

            redrawVisibleRows()

            tableView.cellForRowAtIndexPath(toIndexPath)?.hidden = true
        }

        return toIndexPath
    }

    private func cleanupReorderingAction() {
        snapShotViewForReordering?.removeFromSuperview()
        redrawVisibleRows()
    }
}

