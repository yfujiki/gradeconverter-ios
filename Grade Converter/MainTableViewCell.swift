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
    var editMode: Bool = false
    private var scrolling: Bool = false

    @IBOutlet private weak var gradeNameLabel: UILabel!
    @IBOutlet private weak var gradeLabelScrollView: UIScrollView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var handleButton: UIButton!
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

        gradeLabelScrollView.scrollEnabled = !editMode

        updateButtons()
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

    // Comes to this delegate method on left/right button tap
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrolling = false

        didSelectNewGrade()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x

        if let indexes = indexes {

            // Adjust offset when there is no lower grade
            if !gradeLabelScrollViewHasLeftPage() {
                if offsetX < scrollViewWidth {
                    scrollView.contentOffset.x = scrollViewWidth
                    return
                }
            }

            // Adjust offset when there is no higher grade
            if !gradeLabelScrollViewHasRightPage() {
                if offsetX > scrollViewWidth {
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

    // Comes at the end of manual scrolling. Programatic scrolling does not reach here.
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollView.contentOffset.x = scrollViewWidth

        didSelectNewGrade()
    }

    // MARK:- Edit mode
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
    private func gradeLabelScrollViewCenter() -> CGPoint {
        let currentOffset = gradeLabelScrollView.contentOffset
        return CGPointMake(currentOffset.x + gradeLabelScrollView.bounds.width / 2, currentOffset.y + gradeLabelScrollView.bounds.height / 2)
    }

    private func gradeLabelScrollViewHasLeftPage() -> Bool {
        return gradeSystem?.lowerGradeFromIndexes(indexes!) != nil
    }

    private func gradeLabelScrollViewHasRightPage() -> Bool {
        return gradeSystem?.higherGradeFromIndexes(indexes!) != nil
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

    private func updateButtons() {
        if editMode {
            startJiggling()
            deleteButton.hidden = false
            handleButton.hidden = false
            rightArrowButton.hidden = true
            leftArrowButton.hidden = true
        } else {
            stopJiggling()
            deleteButton.hidden = true
            handleButton.hidden = true
            rightArrowButton.hidden = false
            leftArrowButton.hidden = false

            leftArrowButton.enabled = gradeLabelScrollViewHasLeftPage()
            rightArrowButton.enabled = gradeLabelScrollViewHasRightPage()
        }
    }

    private func updateBorder() {
        if !editMode && gradeSystem?.isBaseSystem == true {
            cardView.layer.borderWidth = CGFloat(5 / UIScreen.mainScreen().scale)
            cardView.layer.borderColor = UIColor.myLightAquaColor().CGColor
        } else {
            cardView.layer.borderWidth = 0
            cardView.layer.borderColor = nil
        }
    }
}
