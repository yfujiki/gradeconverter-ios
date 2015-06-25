//
//  AddTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

class AddTableViewCell: UITableViewCell {

    @IBOutlet private weak var cardView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = 10
        cardView.backgroundColor = UIColor.addColor()
    }
}
