//
//  MainTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

protocol MainTableViewCellDelegate: NSObjectProtocol {
    func didDeleteCell(_ cell: MainTableViewCell)
    func didSelectNewIndexes(_ indexes: [Int], on gradeSystem: GradeSystem, cell: MainTableViewCell)
}

class MainTableViewCell: UITableViewCell, UIScrollViewDelegate {
    fileprivate let kAnimationRotateDeg = CGFloat(0.5) * CGFloat(Double.pi) / CGFloat(180.0)

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
    weak var delegate: MainTableViewCellDelegate?
    var editMode: Bool = false
    fileprivate var scrolling: Bool = false

    @IBOutlet fileprivate weak var gradeNameLabel: UILabel!
    @IBOutlet fileprivate weak var gradeLabelScrollView: UIScrollView!
    @IBOutlet fileprivate weak var cardView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var handleButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var categoryImageView: UIImageView!

    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!

    @IBAction func deleteButtonTapped(_: AnyObject) {
        delegate?.didDeleteCell(self)
    }

    @IBAction func leftButtonTapped(_: AnyObject) {
        if !scrolling && gradeLabelScrollViewHasLeftPage() {
            let currentOffset = gradeLabelScrollView.contentOffset
            let nextOffset = CGPoint(x: currentOffset.x - gradeLabelScrollView.bounds.width, y: currentOffset.y)
            gradeLabelScrollView.setContentOffset(nextOffset, animated: true)
            scrolling = true
        }
    }

    @IBAction func rightButtonTapped(_: AnyObject) {
        if !scrolling && gradeLabelScrollViewHasRightPage() {
            let currentOffset = gradeLabelScrollView.contentOffset
            let nextOffset = CGPoint(x: currentOffset.x + gradeLabelScrollView.bounds.width, y: currentOffset.y)
            gradeLabelScrollView.setContentOffset(nextOffset, animated: true)
            scrolling = true
        }
    }

    fileprivate lazy var gradeLabels: [UILabel] = {
        [
            MainTableViewCell.newGradeLabel(),
            MainTableViewCell.newGradeLabel(),
            MainTableViewCell.newGradeLabel(),
        ]
    }()

    fileprivate var scrollViewWidth: CGFloat {
        return gradeLabelScrollView.frame.width
    }

    fileprivate var scrollViewHeight: CGFloat {
        return gradeLabelScrollView.frame.height
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = 4

        gradeLabelScrollView.delegate = self
        if let gestureRecognizers = gradeLabelScrollView.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers.makeIterator() {
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
            gradeNameLabel.text = gradeSystem.localizedName
            categoryImageView.image = categoryImageFromGradeSystem(gradeSystem)
        }

        if let cardColor = cardColor {
            cardView.backgroundColor = cardColor
        }

        gradeLabelScrollView.isScrollEnabled = !editMode

        updateButtons()
        updateBorder()
    }

    func configureGradeLabels() {
        for i in 0 ..< gradeLabels.count {
            configureGradeLabelAtIndex(i)
        }

        gradeLabelScrollView.contentSize = CGSize(width: scrollViewWidth * 3, height: scrollViewHeight)
    }

    func configureInitialContentOffset() {
        gradeLabelScrollView.contentOffset = CGPoint(x: scrollViewWidth, y: 0)
    }

    fileprivate func configureGradeLabelAtIndex(_ index: Int) {
        let gradeLabel = gradeLabels[index]

        if let gradeSystem = gradeSystem,
            let indexes = indexes {

            switch index {
            case 0:
                gradeLabel.text = NSLocalizedString(gradeSystem.lowerGradeFromIndexes(indexes) ?? "", comment: "Grade itself")
            case 1:
                gradeLabel.text = gradeSystem.localizedGradeAtIndexes(indexes)
            default: // 2
                gradeLabel.text = NSLocalizedString(gradeSystem.higherGradeFromIndexes(indexes) ?? "", comment: "Grade itself")
            }
        }

        let frame = CGRect(x: scrollViewWidth * CGFloat(index), y: 0, width: scrollViewWidth, height: scrollViewHeight)
        gradeLabel.frame = frame
    }

    // MARK: - UIScrollViewDelegate

    // Comes to this delegate method on left/right button tap
    func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        scrolling = false

        didSelectNewGrade()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = scrollViewWidth

        didSelectNewGrade()
    }

    // MARK: - Edit mode
    fileprivate func startJiggling() {
        // The jiggle animation is going to block UI Test.
        if ProcessInfo.processInfo.environment.index(forKey: "UITEST") != nil {
            return
        }

        let leftWobble = CGAffineTransform(rotationAngle: -kAnimationRotateDeg)
        let rightWobble = CGAffineTransform(rotationAngle: kAnimationRotateDeg)

        transform = leftWobble

        UIView.animate(withDuration: 0.1, delay: 0, options: ([.autoreverse, .allowUserInteraction, .repeat]), animations: { [weak self] () in
            UIView.setAnimationRepeatCount(Float(NSNotFound))
            self?.transform = rightWobble
            return
        }, completion: { (_: Bool) in
        })
    }

    fileprivate func stopJiggling() {
        layer.removeAllAnimations()
        transform = CGAffineTransform.identity
    }

    func cardViewSnapshot() -> UIImageView? {
        return cardView.snapshot()
    }

    // MARK: - Private methods
    fileprivate func gradeLabelScrollViewCenter() -> CGPoint {
        let currentOffset = gradeLabelScrollView.contentOffset
        return CGPoint(x: currentOffset.x + gradeLabelScrollView.bounds.width / 2, y: currentOffset.y + gradeLabelScrollView.bounds.height / 2)
    }

    fileprivate func gradeLabelScrollViewHasLeftPage() -> Bool {
        return gradeSystem?.lowerGradeFromIndexes(indexes!) != nil
    }

    fileprivate func gradeLabelScrollViewHasRightPage() -> Bool {
        return gradeSystem?.higherGradeFromIndexes(indexes!) != nil
    }

    fileprivate class func newGradeLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: FontNameForCurrentLang(), size: 40)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.baselineAdjustment = UIBaselineAdjustment.alignCenters

        return label
    }

    fileprivate func didSelectNewGrade() {
        delegate?.didSelectNewIndexes(indexes ?? [], on: gradeSystem!, cell: self)
    }

    fileprivate func updateButtons() {
        if editMode {
            startJiggling()
            deleteButton.isHidden = false
            handleButton.isHidden = false
            rightArrowButton.isHidden = true
            leftArrowButton.isHidden = true
        } else {
            stopJiggling()
            deleteButton.isHidden = true
            handleButton.isHidden = true
            rightArrowButton.isHidden = false
            leftArrowButton.isHidden = false

            leftArrowButton.isEnabled = gradeLabelScrollViewHasLeftPage()
            rightArrowButton.isEnabled = gradeLabelScrollViewHasRightPage()
        }
    }

    fileprivate func updateBorder() {
        if !editMode && SystemLocalStorage().isBaseSystem(gradeSystem) {
            cardView.layer.masksToBounds = false
            cardView.layer.shadowColor = UIColor.myLightAquaColor().cgColor
            cardView.layer.shadowOffset = CGSize.zero
            cardView.layer.shadowRadius = CGFloat(8 / UIScreen.main.scale)
            cardView.layer.shadowOpacity = 1
            cardView.layer.borderWidth = CGFloat(8 / UIScreen.main.scale)
            cardView.layer.borderColor = UIColor.myLightAquaColor().cgColor
        } else {
            cardView.layer.masksToBounds = true
            cardView.layer.shadowColor = nil
            cardView.layer.shadowRadius = 0
            cardView.layer.borderWidth = 0
            cardView.layer.borderColor = nil
        }
    }

    fileprivate func categoryImageFromGradeSystem(_ gradeSystem: GradeSystem) -> UIImage? {
        let imageName = gradeSystem.category == "Sports" ? "sports" : "boulder"

        return UIImage(named: NSLocalizedString(imageName, comment: "Image name for climbing category."))
    }
}
