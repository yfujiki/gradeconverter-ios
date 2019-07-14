//
//  AddTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class AddTableViewCell: UITableViewCell {

    class var kCellHeight: CGFloat {
        if UIDevice.current.hasNotch {
            return 120
        } else {
            return 96
        }
    }

    @IBOutlet fileprivate weak var upperCardView: UIView!
    @IBOutlet fileprivate weak var lowerCardView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var lowerCardLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lowerCardTrailingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        upperCardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        upperCardView.layer.cornerRadius = 4

        if UIDevice.current.hasNotch {
            lowerCardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            lowerCardView.layer.cornerRadius = 36

            // To fix mysteryous 1 px offset on the notch devices on the bottom.
            // It may be fixed in the later OS and this may byte us back.
            lowerCardLeadingConstraint.constant = -1
            lowerCardTrailingConstraint.constant = 1
        } else {
            lowerCardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            lowerCardView.layer.cornerRadius = 4

            lowerCardLeadingConstraint.constant = 0
            lowerCardTrailingConstraint.constant = 0
        }

        [upperCardView, lowerCardView].forEach { cardView in
            cardView?.backgroundColor = UIColor.addColor()
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated _: Bool) {
        if highlighted {
            [upperCardView, lowerCardView].forEach { cardView in
                cardView.alpha = 0.8
            }
            label.textColor = UIColor.gray
        } else {
            [upperCardView, lowerCardView].forEach { cardView in
                cardView.alpha = 1.0
            }
            label.textColor = UIColor.black
        }
    }
}
