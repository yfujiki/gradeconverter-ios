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

    override func awakeFromNib() {
        super.awakeFromNib()

        upperCardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        upperCardView.layer.cornerRadius = 4

        if UIDevice.current.hasNotch {
            lowerCardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            lowerCardView.layer.cornerRadius = 36
        } else {
            lowerCardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            lowerCardView.layer.cornerRadius = 4
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
