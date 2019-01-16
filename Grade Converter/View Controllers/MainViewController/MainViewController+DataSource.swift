//
//  MainViewControllerTableViewDataSource.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/16/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation
import RxDataSources

extension MainViewController {
    func dataSource() -> RxTableViewSectionedAnimatedDataSource<MainViewModel.MainModelSection> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { [weak self] _, table, indexPath, model in
                if let gradeModel = model as? MainViewModel.GradeModel {
                    let cell = table.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell

                    cell.delegate = self
                    cell.backgroundColor = UIColor.clear

                    cell.gradeSystem = gradeModel.gradeSystem
                    cell.indexes = gradeModel.currentIndexes
                    let colors = UIColor.myColors()
                    cell.cardColor = colors[indexPath.row % colors.count]

                    return cell
                } else {
                    let cell = table.dequeueReusableCell(withIdentifier: "AddTableViewCell", for: indexPath) as! AddTableViewCell

                    cell.backgroundColor = UIColor.clear
                    cell.isHidden = self?.isEditing ?? false

                    return cell
                }
            },
            canEditRowAtIndexPath: { _, _ in
                false
            },
            canMoveRowAtIndexPath: { _, _ in
                false
            }
        )
    }
}
