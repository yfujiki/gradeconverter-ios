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

enum NotificationTypes {
    case systemSelectionChangedNotification
    case currentIndexChangedNotification
    case baseSystemChangedNotification

    func value() -> String {
        switch self {
        case .systemSelectionChangedNotification:
            return "com.yfujiki.gradeConverter.SystemSelectionChangedNotification"
        case .currentIndexChangedNotification:
            return "com.yfujiki.gradeConverter.CurrentIndexesChangedNotification"
        case .baseSystemChangedNotification:
            return "com.yfujiki.gradeConverter.BaseSystemChangedNotification"
        }
    }

    func notificationName() -> Notification.Name {
        return Notification.Name(value())
    }

    enum NotificationKeys {
        case selectedSystemsKey
        case currentIndexesKey
        case baseSystemKey

        func value() -> String {
            switch self {
            case .selectedSystemsKey:
                return "com.yfujiki.gradeConverter.SystemSelectionChangedNotification.SelectedSystemsKey"
            case .currentIndexesKey:
                return "com.yfujiki.gradeConverter.CurrentIndexesChangedNotification.CurrentIndexesKey"
            case .baseSystemKey:
                return "com.yfujiki.gradeConverter.BaseSystemChangedNotification.BaseSystemKey"
            }
        }
    }
}

let kSupportEmailAddress = "support@responsivebyt.es"
let kSupportEmailSubject = NSLocalizedString("[Support] About Grade Converter", comment: "Support Email Title")

func SystemLocalStorage() -> LocalStorage {
    return (UIApplication.shared.delegate as! AppDelegate).localStorage
}
