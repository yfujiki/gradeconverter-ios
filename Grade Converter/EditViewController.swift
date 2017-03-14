//
//  EditViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, EditTableViewCellDelegate {
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var imageView: UIImageView!

    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    fileprivate var kCellHeight: CGFloat = 96

    fileprivate let allGradeSystems = GradeSystemTable.sharedInstance.gradeSystems()
    fileprivate var gradeSystems = [GradeSystem]()
    fileprivate var observers = [NSObjectProtocol]()

    fileprivate lazy var blurEffectView: UIVisualEffectView = { [unowned self] _ in
        let effect = UIBlurEffect(style: .light)
        var effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.view.bounds

        return effectView
    }()

    fileprivate func updateGradeSystems() {
        gradeSystems = allGradeSystems.filter { (gradeSystem: GradeSystem) -> Bool in
            return !UserDefaults.standard.selectedGradeSystems().contains(gradeSystem)
        }
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateGradeSystems()

        tableView.register(UINib(nibName: "EditTableViewCell", bundle: nil), forCellReuseIdentifier: "EditTableViewCell")

        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kNSUserDefaultsSystemSelectionChangedNotification), object: nil, queue: nil) { [weak self] _ in
            self?.updateGradeSystems()
        })

        imageView.addSubview(blurEffectView)
        setConstraintsForBlurEffectView()

        tableView.tableFooterView = UIView()
    }

    fileprivate func setConstraintsForBlurEffectView() {
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["imageView": imageView, "blurEffectView": blurEffectView] as [String : Any]
        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[blurEffectView]|", options: .alignAllCenterX, metrics: nil, views: views))
        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurEffectView]|", options: .alignAllCenterY, metrics: nil, views: views))
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView _: UITableView, numberOfRowsInSection _: Int) -> Int {
        return gradeSystems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditTableViewCell") as! EditTableViewCell
        cell.delegate = self
        cell.gradeSystem = gradeSystems[indexPath.row]

        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView _: UITableView, estimatedHeightForRowAtIndexPath _: IndexPath) -> CGFloat {
        return kCellHeight
    }

    func tableView(tableView _: UITableView, heightForRowAtIndexPath _: IndexPath) -> CGFloat {
        return kCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        addGradeFromIndexPath(indexPath)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - EditTableViewCellDelegate

    func didAddGradeCell(_ cell: EditTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: cell) {
            addGradeFromIndexPath(selectedIndexPath)
        }
    }

    fileprivate func addGradeFromIndexPath(_ indexPath: IndexPath) {
        tableView.beginUpdates()
        let gradeSystem = gradeSystems[indexPath.row]
        UserDefaults.standard.addSelectedGradeSystem(gradeSystem)
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.endUpdates()
    }
}
