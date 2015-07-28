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

func FontNameForCurrentLang() -> String {
    if CurrentLang() == .ja {
        return "rounded-mplus-2p-light"
    } else {
        return "ChalkboardSE-Regular"
    }
}

func BoldFontNameForCurrentLang() -> String {
    if CurrentLang() == .ja {
        return "rounded-mplus-2p-heavy"
    } else {
        return "ChalkboardSE-Bold"
    }
}

func NavigationBarTitleFontSize() -> CGFloat {
    if CurrentLang() == .ja {
        return CGFloat(22)
    } else {
        return CGFloat(28)
    }
}

func NavigationBarItemFontSize() -> CGFloat {
    if CurrentLang() == .ja {
        return CGFloat(18)
    } else {
        return CGFloat(22)
    }
}
