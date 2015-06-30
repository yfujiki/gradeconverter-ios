//
//  EditTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class EditTableViewCell: UITableViewCell {

    @IBOutlet private weak var gradeNameLabel: UILabel!
    @IBOutlet weak var gradeCategoryLabel: UILabel!

    var gradeSystem: GradeSystem?

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = UIColor.clearColor()

        gradeNameLabel.text = gradeSystem?.name ?? ""
        gradeCategoryLabel.text = gradeSystem?.category ?? ""
    }
}
