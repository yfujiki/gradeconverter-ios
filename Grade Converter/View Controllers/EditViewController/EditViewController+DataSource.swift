//
//  EditViewController+DataSource.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/16/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation
import RxDataSources

extension EditViewController {
    func dataSource() -> RxTableViewSectionedAnimatedDataSource<EditViewModel.EditModelSection> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { [weak self] _, table, indexPath, model in
                let cell = table.dequeueReusableCell(withIdentifier: "EditTableViewCell", for: indexPath) as! EditTableViewCell

                cell.gradeSystem = model.gradeSystem
                cell.delegate = self

                return cell
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
