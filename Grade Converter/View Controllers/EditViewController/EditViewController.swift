//
//  EditViewController.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

class EditViewController: UIViewController {
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var imageView: UIImageView!

    @IBAction func doneButtonTapped(_: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    fileprivate var kCellHeight: CGFloat = 96

    fileprivate lazy var blurEffectView: UIVisualEffectView = { // [unowned self] _ in
        let effect = UIBlurEffect(style: .light)
        var effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.view.bounds

        return effectView
    }()

    fileprivate lazy var viewModel = {
        EditViewModel()
    }()

    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemID: String(describing: type(of: self)),
            AnalyticsParameterItemName: String(describing: type(of: self)),
        ])

        tableView.register(UINib(nibName: "EditTableViewCell", bundle: nil), forCellReuseIdentifier: "EditTableViewCell")

        configureBindings()

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

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: blurEffectView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor),
        ])
    }

    fileprivate func configureBindings() {
        viewModel.editModels.bind(to: tableView.rx.items(dataSource: dataSource())).disposed(by: disposeBag)
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
        let gradeSystem = viewModel.snapshotGradeSystems()[indexPath.row]
        viewModel.addGradeSystem(gradeSystem: gradeSystem)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EditViewController: EditTableViewCellDelegate {
    func didAddGradeCell(_ cell: EditTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: cell) {
            let gradeSystem = viewModel.snapshotGradeSystems()[selectedIndexPath.row]
            viewModel.addGradeSystem(gradeSystem: gradeSystem)
        }
    }
}
