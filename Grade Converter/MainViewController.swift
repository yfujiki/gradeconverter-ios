//
//  MainViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import MessageUI
import iAd
import RxSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, MainTableViewCellDelegate {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    fileprivate var bannerView: ADBannerView?
    fileprivate var bannerViewHeightConstraint: NSLayoutConstraint?

    fileprivate var selectedSystems: [GradeSystem] = []

    fileprivate var kMinimumCellHeight: CGFloat = 96
    fileprivate var kMaximumCellHeight: CGFloat = 96

    fileprivate var observers = [NSObjectProtocol]()
    private var disposeBag = DisposeBag()

    fileprivate lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MainViewController.longPressGestureRecognized(_:)))
        gestureRecognizer.minimumPressDuration = 0.2
        gestureRecognizer.delegate = self

        return gestureRecognizer
    }()

    fileprivate lazy var blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        var effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.imageView.bounds

        return effectView
    }()

    fileprivate func updateSelectedSystems() {
        selectedSystems = UserDefaults.standard.selectedGradeSystems()

        navigationItem.rightBarButtonItem?.isEnabled = selectedSystems.count > 0

        if selectedSystems.count == 0 {
            isEditing = false
        }
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing {
            tableView.addGestureRecognizer(longPressGestureRecognizer)
        } else {
            tableView.removeGestureRecognizer(longPressGestureRecognizer)
        }

        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.accessibilityIdentifier = "Main Navigation Bar"
        }

        let editButton = editButtonItem
        editButton.accessibilityIdentifier = "Edit Button"
        navigationItem.rightBarButtonItem = editButton

        updateSelectedSystems()

        kMaximumCellHeight = tableView.frame.height / 3

        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        tableView.register(UINib(nibName: "AddTableViewCell", bundle: nil), forCellReuseIdentifier: "AddTableViewCell")

        registerForNotifications()

        imageView.addSubview(blurEffectView)
        setConstraintsForBlurEffectView()

        // For now, don't think about ad. This app is probably good as completely free.
        //        #if PRO
        //        #else
        //            showAd()
        //        #endif

        GradeSystemTable.sharedInstance.updated.subscribe(
            onNext: { _ in
                let title = NSLocalizedString("The grade table is updated. Data will reload.", comment: "Title for update alert")
                let ok = OK()
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: ok, style: .cancel, handler: { _ in
                    UserDefaults.standard.setCurrentIndexes(kNSUserDefaultsDefaultIndexes)
                    self.updateSelectedSystems()
                    self.tableView.reloadData()
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        ).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func viewWillTransition(to size: CGSize, with _: UIViewControllerTransitionCoordinator) {

        #if PRO
        #else
            adjustBannerViewToSize(size)
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func showAd() {
        bannerView = ADBannerView(adType: .banner)
        bannerView?.delegate = self
        view.addSubview(bannerView!)
        bannerView?.translatesAutoresizingMaskIntoConstraints = false
        let bannerViewHeight = UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) ? kIAdBannerViewHeightLandscape : kIAdBannerViewHeightPortrait
        bannerViewHeightConstraint = bannerView?.heightAnchor.constraint(equalToConstant: bannerViewHeight)
        bannerViewHeightConstraint?.isActive = true
        bannerView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bannerView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bannerView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        tableView.contentInset = UIEdgeInsetsMake(0, 0, bannerViewHeight, 0)
    }

    fileprivate func adjustBannerViewToSize(_ size: CGSize) {
        let isLandscape = size.height < size.width
        let bannerViewHeight = isLandscape ? kIAdBannerViewHeightLandscape : kIAdBannerViewHeightPortrait
        bannerViewHeightConstraint?.constant = bannerViewHeight

        tableView.contentInset = UIEdgeInsetsMake(0, 0, bannerViewHeight, 0)
    }

    fileprivate func redrawVisibleRows() {
        if let indexPaths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }

    fileprivate func setConstraintsForBlurEffectView() {
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["imageView": imageView, "blurEffectView": blurEffectView] as [String: Any]
        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[blurEffectView]|", options: .alignAllCenterX, metrics: nil, views: views))
        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurEffectView]|", options: .alignAllCenterY, metrics: nil, views: views))
    }

    // MARK: - Notification handlers
    fileprivate func registerForNotifications() {
        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kNSUserDefaultsSystemSelectionChangedNotification), object: nil, queue: nil) { [weak self] _ in
            self?.updateSelectedSystems()
        })

        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kGradeSelectedNotification), object: nil, queue: nil) { [weak self] (notification: Notification!) in
            if let strongSelf = self {
                if let indexes = notification.userInfo?[kNewIndexesKey] as? [Int] {
                    if UserDefaults.standard.currentIndexes() != indexes {
                        UserDefaults.standard.setCurrentIndexes(indexes)

                        if let baseCell = notification.object as? MainTableViewCell {
                            let baseIndexPath = strongSelf.tableView.indexPath(for: baseCell)
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

        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kEmailComposingNotification), object: nil, queue: nil, using: { [weak self] (_: Notification) in
            if MFMailComposeViewController.canSendMail() {
                let composeViewController = MFMailComposeViewController()
                composeViewController.mailComposeDelegate = self
                composeViewController.setToRecipients([kSupportEmailAddress])
                composeViewController.setSubject(kSupportEmailSubject)
                composeViewController.navigationBar.tintColor = UIColor.white

                self?.dismiss(animated: false, completion: { [weak self] () in
                    self?.present(composeViewController, animated: true, completion: nil)
                })
            }
        }))
    }

    fileprivate func updateBaseSystemToIndex(_ index: Int) {
        for i in 0 ..< selectedSystems.count {
            selectedSystems[i].isBaseSystem = (i == index)
        }
    }

    fileprivate func reloadVisibleCellsButCell(_ cell: UITableViewCell, animated: Bool) {

        let indexPaths = tableView.visibleCells.reduce([IndexPath](), { (tmp: [IndexPath], visibleCell: UITableViewCell) -> [IndexPath] in
            var results = tmp
            if let visibleCell = visibleCell as? MainTableViewCell, visibleCell != cell,
                let visibleIndexPath = tableView.indexPath(for: visibleCell) {
                results.append(visibleIndexPath)
            }
            return results
        })

        let animationOption: UITableViewRowAnimation = animated ? .automatic : .none
        tableView.reloadRows(at: indexPaths, with: animationOption)
    }

    fileprivate func reloadOnlyCell(_ cell: UITableViewCell, animated: Bool) {
        if let baseIndexPath = tableView.indexPath(for: cell) {
            let animationOption: UITableViewRowAnimation = animated ? .automatic : .none
            tableView.reloadRows(at: [baseIndexPath], with: animationOption)
        }
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "PresentEdit" {
            let destinationViewController = segue.destination
            destinationViewController.transitioningDelegate = self
            destinationViewController.modalPresentationStyle = .custom
        } else if segue.identifier == "PresentInfo" {
            let destinationViewController = segue.destination
            destinationViewController.transitioningDelegate = self
            destinationViewController.modalPresentationStyle = .custom
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return selectedSystems.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < selectedSystems.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell") as! MainTableViewCell
            cell.delegate = self
            cell.backgroundColor = UIColor.clear

            cell.gradeSystem = selectedSystems[indexPath.row]
            cell.indexes = UserDefaults.standard.currentIndexes()

            let colors = UIColor.myColors()
            cell.cardColor = colors[indexPath.row % colors.count]

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddTableViewCell") as! AddTableViewCell
            cell.backgroundColor = UIColor.clear
            cell.isHidden = isEditing

            return cell
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return kMinimumCellHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < selectedSystems.count {
            let totalHeight = tableView.frame.height - AddTableViewCell.kCellHeight
            let count = selectedSystems.count
            var targetHeight = totalHeight / CGFloat(count)
            targetHeight = min(targetHeight, kMaximumCellHeight)
            targetHeight = max(targetHeight, kMinimumCellHeight)

            return targetHeight
        } else {
            return AddTableViewCell.kCellHeight
        }
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.tag = indexPath.row

        if let mainTableViewCell = cell as? MainTableViewCell {
            mainTableViewCell.configureGradeLabels()
            mainTableViewCell.configureInitialContentOffset()
            mainTableViewCell.editMode = isEditing
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == selectedSystems.count {
            performSegue(withIdentifier: "PresentEdit", sender: self)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        return false
    }

    func reloadTableView() {
        tableView.reloadData()
    }

    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        var transitioning: UIViewControllerAnimatedTransitioning?

        if presented is UINavigationController && presented.childViewControllers.first is EditViewController {
            let editViewTransitioning = SemiModalPresentationAnimatingTransitioning()
            editViewTransitioning.presenting = true
            transitioning = editViewTransitioning
        } else if presented is InfoViewController {
            let infoViewTransitioning = FormSheetPresentationAnimatingTransitioning()
            infoViewTransitioning.presenting = true
            transitioning = infoViewTransitioning
        }

        return transitioning
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var transitioning: UIViewControllerAnimatedTransitioning?

        if dismissed is UINavigationController && dismissed.childViewControllers.first is EditViewController {
            let editViewTransitioning = SemiModalPresentationAnimatingTransitioning()
            editViewTransitioning.presenting = false
            transitioning = editViewTransitioning
        } else if dismissed is InfoViewController {
            let infoViewTransitioning = FormSheetPresentationAnimatingTransitioning()
            infoViewTransitioning.presenting = false
            transitioning = infoViewTransitioning
        }

        return transitioning
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }

    // MARK: - MainTableViewCellDelegate
    func didDeleteCell(_ cell: MainTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.beginUpdates()
            let systemToDelete = selectedSystems[indexPath.row]
            UserDefaults.standard.removeSelectedGradeSystem(systemToDelete)
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.endUpdates()
        }
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: tableView)

        if location.x >= MainTableViewCell.CardViewLeadingConstraint + MainTableViewCell.DeleteButtonLeadingConstraint &&
            location.x <= MainTableViewCell.CardViewLeadingConstraint + MainTableViewCell.DeleteButtonLeadingConstraint + MainTableViewCell.DeleteButtonWidthConstraint {
            return false
        }

        return true
    }

    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    // MARK: - Reordering
    var focusIndexPathOfReordering: IndexPath?
    var snapShotViewForReordering: UIImageView?
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let state = gestureRecognizer.state

        let location = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)

        switch state {
        case .began:
            (focusIndexPathOfReordering, snapShotViewForReordering) = reorderDidBeginAtIndexPath(indexPath)
        case .changed:
            focusIndexPathOfReordering = replaceCellFromIndexPath(focusIndexPathOfReordering, toIndexPath: indexPath)

            if let snapshotView = snapShotViewForReordering {
                snapshotView.center = CGPoint(x: snapshotView.center.x, y: location.y)
            }
        default:
            cleanupReorderingAction()
        }
    }

    fileprivate func reorderDidBeginAtIndexPath(_ indexPath: IndexPath?) -> (IndexPath?, UIImageView?) {
        if let srcIndexPath = indexPath,
            let srcCell = tableView.cellForRow(at: srcIndexPath) as? MainTableViewCell,
            let snapshotView = srcCell.cardViewSnapshot() {
            snapshotView.center = srcCell.center
            tableView.addSubview(snapshotView)

            srcCell.isHidden = true

            return (srcIndexPath, snapshotView)
        }

        return (nil, nil)
    }

    fileprivate func replaceCellFromIndexPath(_ fromIndexPath: IndexPath?, toIndexPath: IndexPath?) -> (IndexPath?) {
        if let fromIndexPath = fromIndexPath, fromIndexPath.row < selectedSystems.count,
            let toIndexPath = toIndexPath, toIndexPath != fromIndexPath && toIndexPath.row < selectedSystems.count {

            let origSystem = selectedSystems[fromIndexPath.row]
            selectedSystems[fromIndexPath.row] = selectedSystems[toIndexPath.row]
            selectedSystems[toIndexPath.row] = origSystem
            tableView.moveRow(at: fromIndexPath, to: toIndexPath)

            redrawVisibleRows()

            tableView.cellForRow(at: toIndexPath)?.isHidden = true
        }

        return toIndexPath
    }

    fileprivate func cleanupReorderingAction() {
        snapShotViewForReordering?.removeFromSuperview()
        redrawVisibleRows()
    }
}

extension MainViewController: ADBannerViewDelegate {
    func bannerView(_: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        NSLog("Failed to load banner : \(error)")
    }
}
