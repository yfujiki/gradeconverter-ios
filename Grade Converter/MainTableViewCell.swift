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
    @IBOutlet private weak var gradeLabelScrollView: UIScrollView!
    @IBOutlet private weak var cardView: UIView!

    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!

    var gradeSystem: GradeSystem?
    var indexes: [Int]?
    var cardColor: UIColor?

    private class func newGradeLabel() -> UILabel {
        var label = UILabel()
        label.font = UIFont.systemFontOfSize(28)
        label.textAlignment = .Center

        return label
    }

    lazy private var gradeLabels: [UILabel] = {
        return [MainTableViewCell.newGradeLabel(),
                MainTableViewCell.newGradeLabel(),
                MainTableViewCell.newGradeLabel()]
    }()

    private var scrollViewWidth: CGFloat {
        return scrollViewWidthConstraint.constant
    }

    private var scrollViewHeight: CGFloat {
        let gradeNameLabelBottom = CGRectGetMaxY(gradeNameLabel.frame)
        let topMargin = gradeNameLabelBottom + scrollViewTopConstraint.constant
        return frame.height - topMargin - scrollViewBottomConstraint.constant
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        gradeLabelScrollView.pagingEnabled = true

        cardView.layer.cornerRadius = 10

        for gradeLabel in gradeLabels {
            gradeLabelScrollView.addSubview(gradeLabel)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let gradeSystem = gradeSystem {
            gradeNameLabel.text = gradeSystem.name
        }

        if let cardColor = cardColor {
            cardView.backgroundColor = cardColor
        }
    }

    func configureGradeLabels() {
        gradeLabelScrollView.contentSize = CGSizeMake(scrollViewWidth * 3, scrollViewHeight)

        for var i=0; i<gradeLabels.count; i++ {
            configureGradeLabelAtIndex(i)
        }
    }

    private func configureGradeLabelAtIndex(index: Int) {
        let gradeLabel = gradeLabels[index]

        if let gradeSystem = gradeSystem,
            let indexes = indexes {

            switch (index) {
            case 0:
                gradeLabel.text = gradeSystem.lowerGradeFromIndexes(indexes)
            case 1:
                gradeLabel.text = gradeSystem.gradeAtIndexes(indexes)
            default: // 2
                gradeLabel.text = gradeSystem.higherGradeFromIndexes(indexes)
            }
        }

        var frame = CGRectMake(scrollViewWidth * CGFloat(index), 0, scrollViewWidth, scrollViewHeight)
        gradeLabel.frame = frame
    }
}
