//
//  EditTableViewCell.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit

protocol EditTableViewCellDelegate: NSObjectProtocol {
    func didAddGradeCell(_ cell: EditTableViewCell)
}

class EditTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet fileprivate weak var gradeNameLabel: UILabel!
    @IBOutlet weak var gradeCategoryLabel: UILabel!

    @IBAction func addButtonTapped(_: AnyObject) {
        delegate?.didAddGradeCell(self)
    }

    var gradeSystem: GradeSystem?
    weak var delegate: EditTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = 4
        cardView.backgroundColor = UIColor.systemLightGrayColor()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = UIColor.clear

        cardView.layer.cornerRadius = 4

        gradeNameLabel.text = gradeSystem?.localizedName ?? ""
        gradeCategoryLabel.text = gradeSystem?.category == nil ? "" : localizedCategoryStringForGradeSystem(gradeSystem!)
    }

    fileprivate func localizedCategoryStringForGradeSystem(_ gradeSystem: GradeSystem) -> String {
        return NSLocalizedString("(\(gradeSystem.category))", comment: "Climbing category in parenthesis")
    }
}
