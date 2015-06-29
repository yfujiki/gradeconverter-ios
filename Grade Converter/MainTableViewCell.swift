//
//  MainTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell, UIScrollViewDelegate {

    @IBOutlet private weak var gradeNameLabel: UILabel!
    @IBOutlet private weak var gradeLabelScrollView: UIScrollView!
    @IBOutlet private weak var cardView: UIView!

    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!

    var gradeSystem: GradeSystem?
    var indexes: [Int]?
    var cardColor: UIColor?

    private class func newGradeLabel() -> UILabel {
        var label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(40)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .Center
        label.baselineAdjustment = UIBaselineAdjustment.AlignCenters

        return label
    }

    lazy private var gradeLabels: [UILabel] = {
        return [MainTableViewCell.newGradeLabel(),
                MainTableViewCell.newGradeLabel(),
                MainTableViewCell.newGradeLabel()]
    }()

    private var scrollViewWidth: CGFloat {
        return gradeLabelScrollView.frame.width
    }

    private var scrollViewHeight: CGFloat {
        return gradeLabelScrollView.frame.height
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = 10

        gradeLabelScrollView.delegate = self
        if let gestureRecognizers = gradeLabelScrollView.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers.generate() {
                if gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UISwipeGestureRecognizer {
                    cardView.addGestureRecognizer(gestureRecognizer as! UIGestureRecognizer)
                }
            }
        }

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
        for var i=0; i<gradeLabels.count; i++ {
            configureGradeLabelAtIndex(i)
        }

        gradeLabelScrollView.contentSize = CGSizeMake(scrollViewWidth * 3, scrollViewHeight)
    }

    func configureInitialContentOffset() {
        gradeLabelScrollView.contentOffset = CGPointMake(scrollViewWidth, 0)
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

    // MARK:- UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x

        if let indexes = indexes {
            if gradeSystem?.lowerGradeFromIndexes(indexes) == nil {
                if offsetX < scrollViewWidth * 1 {
                    scrollView.contentOffset.x = scrollViewWidth
                    return
                }
            }

            if gradeSystem?.higherGradeFromIndexes(indexes) == nil {
                if offsetX > scrollViewWidth * 1 {
                    scrollView.contentOffset.x = scrollViewWidth
                    return
                }
            }

            if offsetX < scrollViewWidth * 0.5 {
                let grade = gradeSystem?.lowerGradeFromIndexes(indexes)
                if let grade = grade,
                   let gradeIndexes = gradeSystem?.indexesForGrade(grade) {
                    self.indexes = gradeIndexes
                }
                scrollView.contentOffset.x += scrollViewWidth
            } else if offsetX > scrollViewWidth * 1.5 {
                let grade = gradeSystem?.higherGradeFromIndexes(indexes)
                if let grade = grade,
                   let gradeIndexes = gradeSystem?.indexesForGrade(grade) {
                    self.indexes = gradeIndexes
                }
                scrollView.contentOffset.x -= scrollViewWidth
            }

            configureGradeLabels()
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollView.contentOffset.x = scrollViewWidth

        let userInfo = [kNewIndexesKey: indexes ?? []]

        NSNotificationCenter.defaultCenter().postNotificationName(kGradeSelectedNotification, object: self, userInfo: userInfo)
    }
}
