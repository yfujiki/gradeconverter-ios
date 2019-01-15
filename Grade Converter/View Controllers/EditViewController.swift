//
//  EditViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import Firebase

class EditViewController: UIViewController {
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var imageView: UIImageView!

    @IBAction func doneButtonTapped(_: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    fileprivate var kCellHeight: CGFloat = 96

    fileprivate let allGradeSystems = GradeSystemTable.sharedInstance.gradeSystems()
    fileprivate var gradeSystems = [GradeSystem]()
    fileprivate var observers = [NSObjectProtocol]()

    fileprivate lazy var blurEffectView: UIVisualEffectView = { // [unowned self] _ in
        let effect = UIBlurEffect(style: .light)
        var effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.view.bounds

        return effectView
    }()

    fileprivate func updateGradeSystems() {
        gradeSystems = allGradeSystems.filter { (gradeSystem: GradeSystem) -> Bool in
            SystemLocalStorage().selectedGradeSystems().contains(gradeSystem)
        }
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemID: type(of: self),
            AnalyticsParameterItemName: type(of: self),
        ])

        updateGradeSystems()

        tableView.register(UINib(nibName: "EditTableViewCell", bundle: nil), forCellReuseIdentifier: "EditTableViewCell")

        observers.append(NotificationCenter.default.addObserver(forName: NotificationTypes.systemSelectionChangedNotification.notificationName(), object: nil, queue: nil) { [weak self] _ in
            self?.updateGradeSystems()
        })

        imageView.addSubview(blurEffectView)
        setConstraintsForBlurEffectView()

        tableView.tableFooterView = UIView()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
    }

    fileprivate func setConstraintsForBlurEffectView() {
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["imageView": imageView, "blurEffectView": blurEffectView] as [String: Any]
        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[blurEffectView]|", options: .alignAllCenterX, metrics: nil, views: views))
        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurEffectView]|", options: .alignAllCenterY, metrics: nil, views: views))
    }
}

extension EditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        return gradeSystems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditTableViewCell") as! EditTableViewCell
        cell.delegate = self
        cell.gradeSystem = gradeSystems[indexPath.row]

        return cell
    }
}

extension EditViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate
    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return kCellHeight
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return kCellHeight
    }

    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addGradeFromIndexPath(indexPath)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EditViewController: EditTableViewCellDelegate {
    func didAddGradeCell(_ cell: EditTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: cell) {
            addGradeFromIndexPath(selectedIndexPath)
        }
    }

    fileprivate func addGradeFromIndexPath(_ indexPath: IndexPath) {
        tableView.beginUpdates()
        let gradeSystem = gradeSystems[indexPath.row]
        SystemLocalStorage().addSelectedGradeSystem(gradeSystem)
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.endUpdates()
    }
}
