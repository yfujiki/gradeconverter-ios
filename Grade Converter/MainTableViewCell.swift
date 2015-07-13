//
//  MainTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

protocol MainTableViewCellDelegate: NSObjectProtocol {
    func didDeleteCell(cell: MainTableViewCell)
}

class MainTableViewCell: UITableViewCell, UIScrollViewDelegate {
    private let kAnimationRotateDeg = CGFloat(1.0) * CGFloat(M_PI) / CGFloat(180.0)

    class var CardViewLeadingConstraint: CGFloat {
        return 16
    }

    class var DeleteButtonLeadingConstraint: CGFloat {
        return 16
    }

    class var DeleteButtonWidthConstraint: CGFloat {
        return 24
    }

    var gradeSystem: GradeSystem?
    var indexes: [Int]?
    var cardColor: UIColor?
    var delegate: MainTableViewCellDelegate?
    private var scrolling: Bool = false

    private var isInEditMode: Bool {
        return !deleteButton.hidden
    }

    @IBOutlet private weak var gradeNameLabel: UILabel!
    @IBOutlet private weak var gradeLabelScrollView: UIScrollView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!

    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!

    @IBAction func deleteButtonTapped(sender: AnyObject) {
        delegate?.didDeleteCell(self)
    }

    @IBAction func leftButtonTapped(sender: AnyObject) {
        if !scrolling && gradeLabelScrollViewHasLeftPage() {
            let currentOffset = gradeLabelScrollView.contentOffset
            let nextOffset = CGPointMake(currentOffset.x - gradeLabelScrollView.bounds.width, currentOffset.y)
            gradeLabelScrollView.setContentOffset(nextOffset, animated: true)
            scrolling = true
        }
    }

    @IBAction func rightButtonTapped(sender: AnyObject) {
        if !scrolling && gradeLabelScrollViewHasRightPage() {
            let currentOffset = gradeLabelScrollView.contentOffset
            let nextOffset = CGPointMake(currentOffset.x + gradeLabelScrollView.bounds.width, currentOffset.y)
            gradeLabelScrollView.setContentOffset(nextOffset, animated: true)
            scrolling = true
        }
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

        cardView.layer.cornerRadius = 4

        gradeLabelScrollView.delegate = self
        if let gestureRecognizers = gradeLabelScrollView.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers.generate() {
                if gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UISwipeGestureRecognizer {
                    cardView.addGestureRecognizer(gestureRecognizer as UIGestureRecognizer)
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

        updateBorder()
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

        let frame = CGRectMake(scrollViewWidth * CGFloat(index), 0, scrollViewWidth, scrollViewHeight)
        gradeLabel.frame = frame
    }

    // MARK:- UIScrollViewDelegate

    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrolling = false

        didSelectNewGrade()
    }

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

        leftArrowButton.enabled = gradeLabelScrollViewHasLeftPage()
        rightArrowButton.enabled = gradeLabelScrollViewHasRightPage()

        didSelectNewGrade()
    }

    // MARK:- Edit mode
    override func setEditing(editing: Bool, animated: Bool) {
        if editing {
            startJiggling()
            deleteButton.hidden = false
            rightArrowButton.hidden = true
            leftArrowButton.hidden = true
        } else {
            stopJiggling()
            deleteButton.hidden = true
            rightArrowButton.hidden = false
            leftArrowButton.hidden = false
        }

        gradeLabelScrollView.scrollEnabled = !editing
    }

    private func startJiggling() {
        let leftWobble = CGAffineTransformMakeRotation(-kAnimationRotateDeg)
        let rightWobble = CGAffineTransformMakeRotation(kAnimationRotateDeg)

        transform = leftWobble

        UIView.animateWithDuration(0.1, delay: 0, options: ([.Autoreverse, .AllowUserInteraction, .Repeat]), animations: { [weak self] () -> Void in
            UIView.setAnimationRepeatCount(Float(NSNotFound))
            self?.transform = rightWobble
            return
            }, completion: { (success: Bool) -> Void in
        })
    }

    private func stopJiggling() {
        layer.removeAllAnimations()
        transform = CGAffineTransformIdentity
    }

    func cardViewSnapshot() -> UIImageView {
        return cardView.snapshot()
    }

    // MARK:- Private methods
    private func gradeLabelScrollViewHasLeftPage() -> Bool {
        let currentCenter = gradeNameLabel.center
        let nextCenter = CGPointMake(currentCenter.x - gradeLabelScrollView.bounds.width, currentCenter.y)

        return gradeLabelScrollViewContainsPoint(nextCenter)
    }

    private func gradeLabelScrollViewHasRightPage() -> Bool {
        let currentCenter = gradeNameLabel.center
        let nextCenter = CGPointMake(currentCenter.x + gradeLabelScrollView.bounds.width, currentCenter.y)

        return gradeLabelScrollViewContainsPoint(nextCenter)
    }

    private func gradeLabelScrollViewContainsPoint(offset: CGPoint) -> Bool {
        let contentFrame = CGRect(origin: CGPointZero, size: gradeLabelScrollView.contentSize)

        return CGRectContainsPoint(contentFrame, offset)
    }

    private class func newGradeLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(40)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .Center
        label.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        
        return label
    }

    private func didSelectNewGrade() {
        let userInfo = [kNewIndexesKey: indexes ?? []]
        NSNotificationCenter.defaultCenter().postNotificationName(kGradeSelectedNotification, object: self, userInfo: userInfo)
    }

    private func updateBorder() {
        if !isInEditMode && gradeSystem?.isBaseSystem == true {
            cardView.layer.borderWidth = CGFloat(10 / UIScreen.mainScreen().scale)
            cardView.layer.borderColor = UIColor.whiteColor().CGColor
        } else {
            cardView.layer.borderWidth = 0
            cardView.layer.borderColor = nil
        }
    }
}
