//
//  Localization.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 7/27/15.
//  Copyright © 2015 Responsive Bytes. All rights reserved.
//

import Foundation
import UIKit

enum Country: Int {
    case us = 0
    case jp
    case others
}

enum Lang: Int {
    case en = 0
    case ja
    case others
}

func CurrentCountry() -> Country {
    if let countryCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String {
        if countryCode == "US" {
            return Country.us
        } else if countryCode == "JP" {
            return Country.jp
        }
    }

    return Country.others
}

func CurrentLang() -> Lang {
    if let currentLang = Bundle.main.preferredLocalizations.first {
        if currentLang == "en" {
            return Lang.en
        } else if currentLang == "ja" {
            return Lang.ja
        }
    }

    return Lang.others
}

func FontNameForCurrentLang() -> String {
    if CurrentLang() == .ja {
        return "rounded-mplus-2p-light"
    } else {
        return "Gill Sans"
    }
}

func BoldFontNameForCurrentLang() -> String {
    if CurrentLang() == .ja {
        return "rounded-mplus-2p-heavy"
    } else {
        return "Gill Sans"
    }
}

func NavigationBarTitleFontSize() -> CGFloat {
    if CurrentLang() == .ja {
        return CGFloat(22)
    } else {
        return CGFloat(26)
    }
}

func NavigationBarItemFontSize() -> CGFloat {
    if CurrentLang() == .ja {
        return CGFloat(18)
    } else {
        return CGFloat(22)
    }
}

func OK() -> String {
    return NSLocalizedString("OK", comment: "OK")
}
