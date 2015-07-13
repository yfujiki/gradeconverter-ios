//
//  EditTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

protocol EditTableViewCellDelegate: NSObjectProtocol {
    func didAddGradeCell(cell: EditTableViewCell)
}

class EditTableViewCell: UITableViewCell {

    @IBOutlet private weak var gradeNameLabel: UILabel!
    @IBOutlet weak var gradeCategoryLabel: UILabel!

    @IBAction func addButtonTapped(sender: AnyObject) {
        delegate?.didAddGradeCell(self)
    }

    var gradeSystem: GradeSystem?
    var delegate: EditTableViewCellDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = UIColor.clearColor()

        gradeNameLabel.text = gradeSystem?.name ?? ""
        gradeCategoryLabel.text = gradeSystem?.category == nil ? "" : "(\(gradeSystem!.category))"
    }
}
