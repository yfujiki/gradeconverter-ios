//
//  MainTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet private weak var gradeNameLabel: UILabel!
    @IBOutlet private weak var gradeLabel: UILabel!
    @IBOutlet private weak var cardView: UIView!

    var gradeSystem: GradeSystem?
    var indexes: [Int]?

    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = 10
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let gradeSystem = gradeSystem {
            gradeNameLabel.text = gradeSystem.name

            if let indexes = indexes {
                let grade = gradeSystem.gradeAtIndexes(indexes)
                gradeLabel.text = grade
            }
        }
    }
}
