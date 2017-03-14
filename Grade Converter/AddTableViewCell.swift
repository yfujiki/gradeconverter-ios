//
//  AddTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class AddTableViewCell: UITableViewCell {

    class var kCellHeight: CGFloat { return 96 }

    @IBOutlet fileprivate weak var cardView: UIView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = 4
        cardView.backgroundColor = UIColor.addColor()
    }

    override func setHighlighted(_ highlighted: Bool, animated _: Bool) {
        if highlighted {
            cardView.alpha = 0.8
            label.textColor = UIColor.gray
        } else {
            cardView.alpha = 1.0
            label.textColor = UIColor.black
        }
    }
}
