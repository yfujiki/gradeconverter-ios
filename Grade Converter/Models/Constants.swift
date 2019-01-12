//
//  Constants.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/28/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

let kGradeSystemTableURLPath = "https://s3.amazonaws.com/gradeconverter.yfujiki.com/GradeSystemTable.csv"

let kNSUserDefaultsSystemSelectionChangedNotification = "com.yfujiki.gradeConverter.SystemSelectionChangedNotification"
let kGradeSelectedNotification = "com.yfujiki.GradeConverter.GradeSelectedNotification"
let kEmailComposingNotification = "com.yfujiki.GradeConverter.EmailComposingNotification"
let kNewIndexesKey = "newIndexesKey"

let kSupportEmailAddress = "support@responsivebyt.es"
let kSupportEmailSubject = NSLocalizedString("[Support] About Grade Converter", comment: "Support Email Title")

func SystemLocalStorage() -> LocalStorage {
    return (UIApplication.shared.delegate as! AppDelegate).localStorage
}
