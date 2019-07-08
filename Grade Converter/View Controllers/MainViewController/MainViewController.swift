//
//  MainViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import MessageUI
import RxSwift
import RxCocoa
import Firebase

class MainViewController: UIViewController, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, MainTableViewCellDelegate {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!

    fileprivate lazy var viewModel = {
        MainViewModel()
    }()

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

        configureBindings()

        kMaximumCellHeight = tableView.frame.height / 3

        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        tableView.register(UINib(nibName: "AddTableViewCell", bundle: nil), forCellReuseIdentifier: "AddTableViewCell")
        tableView.contentInsetAdjustmentBehavior = .never

        imageView.addSubview(blurEffectView)
        setConstraintsForBlurEffectView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemID: type(of: self),
            AnalyticsParameterItemName: type(of: self),
        ])
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if tableView.contentSize.height < size.height {
            // If entire contents fits in the screen of the new orientation, then scroll to the top
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
    }

    fileprivate func configureBindings() {
        viewModel.mainModels.bind(to: tableView.rx.items(dataSource: dataSource())).disposed(by: disposeBag)
    }

    fileprivate func setConstraintsForBlurEffectView() {
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: imageView.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
        ])
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

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return kMinimumCellHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < viewModel.selectedGradeSystemCount {
            let totalHeight = tableView.frame.height - AddTableViewCell.kCellHeight
            let count = viewModel.selectedGradeSystemCount
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
        if indexPath.row == viewModel.selectedGradeSystemCount {
            performSegue(withIdentifier: "PresentEdit", sender: self)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func reloadTableView() {
        tableView.reloadData()
    }

    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        var transitioning: UIViewControllerAnimatedTransitioning?

        if presented is UINavigationController && presented.children.first is EditViewController {
            let editViewTransitioning = SemiModalPresentationAnimatingTransitioning()
            editViewTransitioning.presenting = true
            transitioning = editViewTransitioning
        } else if let infoViewController = presented as? InfoViewController {
            let infoViewTransitioning = FormSheetPresentationAnimatingTransitioning()
            infoViewController.delegate = self
            infoViewTransitioning.presenting = true
            transitioning = infoViewTransitioning
        }

        return transitioning
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var transitioning: UIViewControllerAnimatedTransitioning?

        if dismissed is UINavigationController && dismissed.children.first is EditViewController {
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
            viewModel.deleteGradeSystem(at: indexPath.row, commit: true)
        }
    }

    func didSelectNewIndexes(_ indexes: [Int], on gradeSystem: GradeSystem, cell _: MainTableViewCell) {
        // This order is important. Set base system first before changing current indexes.
        viewModel.updateBaseSystem(to: gradeSystem)
        viewModel.setCurrentIndexes(indexes)
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
    @objc func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
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
        if let fromIndexPath = fromIndexPath, fromIndexPath.row < viewModel.selectedGradeSystemCount,
            let toIndexPath = toIndexPath, toIndexPath != fromIndexPath && toIndexPath.row < viewModel.selectedGradeSystemCount {

            viewModel.reorderGradeSystem(from: fromIndexPath.row, to: toIndexPath.row, commit: false)

            //            tableView.cellForRow(at: toIndexPath)?.isHidden = true
        }

        return toIndexPath
    }

    fileprivate func cleanupReorderingAction() {
        snapShotViewForReordering?.removeFromSuperview()
        viewModel.commitGradeSystemSelectionChange()

        if let srcIndexPath = focusIndexPathOfReordering {
            let srcCell = tableView.cellForRow(at: srcIndexPath) as? MainTableViewCell
            srcCell?.isHidden = false
        }
    }
}
