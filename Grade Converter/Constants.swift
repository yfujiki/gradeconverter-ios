//
//  Constants.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/28/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import Foundation

let kNSUserDefaultsSystemSelectionChangedNotification = "com.responsivebytes.gradeConverter.SystemSelectionChangedNotification"
let kGradeSelectedNotification = "com.responsivebytes.GradeConverter.GradeSelectedNotification"
let kEmailComposingNotification = "com.responsivebytes.GradeConverter.EmailComposingNotification"
let kNewIndexesKey = "newIndexesKey"
let kSupportEmailAddress = "support@responsivebyt.es"
let kSupportEmailSubject = NSLocalizedString("[Support] About Grade Converter", comment: "Support Email Title")

enum Country: Int {
    case US = 0
    case JP
    case Others
}

enum Lang: Int {
    case en = 0
    case ja
    case others
}

func CurrentCountry() -> Country {
    if let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String {
        if countryCode == "US" {
            return Country.US
        } else if countryCode == "JP" {
            return Country.JP
        }
    }

    return Country.Others
}

func CurrentLang() -> Lang {
    if let currentLang = NSBundle.mainBundle().preferredLocalizations.first {
        if currentLang == "en" {
            return Lang.en
        } else if currentLang == "ja" {
            return Lang.ja
        }
    }

    return Lang.others
}