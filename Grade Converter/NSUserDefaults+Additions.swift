//
//  NSUserDefaults+Additions.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import Foundation

let kNSUserDefaultsCurrentIndexes = "com.responsivebytes.gradeConverter.currentIndexes"
let kNSUserDefaultsSelectedGradeSystems = "com.responsivebytes.gradeConverter.selectedGradeSystems"
let kNSUserDefaultsGradeNameKey = "gradeName"
let kNSUserDefaultsGradeCategoryKey = "gradeCategory"

let kNSUserDefaultsDefaultIndexes = [Int(17)]

func kNSUserDefaultsDefaultGradeSystem() -> [GradeSystem] {
    if let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String {
        if countryCode == "JP" {
            return [
                GradeSystemTable.sharedInstance.gradeSystemForName("Ogawayama", category: "Boulder")!,
                GradeSystemTable.sharedInstance.gradeSystemForName("Hueco", category: "Boulder")!,
                GradeSystemTable.sharedInstance.gradeSystemForName("Yosemite Decimal System", category: "Sports")!
            ]
        }
    }

    // US and everything else
    return [
        GradeSystemTable.sharedInstance.gradeSystemForName("Yosemite Decimal System", category: "Sports")!,
        GradeSystemTable.sharedInstance.gradeSystemForName("Hueco", category: "Boulder")!
    ]
}

extension NSUserDefaults {
    func setCurrentIndexes(indexes: [Int]) {
        NSUserDefaults.standardUserDefaults().setObject(indexes, forKey: kNSUserDefaultsCurrentIndexes)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func currentIndexes() -> [Int] {
        let indexes = NSUserDefaults.standardUserDefaults().arrayForKey(kNSUserDefaultsCurrentIndexes) as? [Int]

        return indexes ?? kNSUserDefaultsDefaultIndexes
    }

    func setSelectedGradeSystems(gradeSystems:[GradeSystem]) {
        let systemKeys = gradeSystems.map { (gradeSystem: GradeSystem) -> [String: String] in
            let name = gradeSystem.name
            let category = gradeSystem.category
            return [kNSUserDefaultsGradeNameKey: name, kNSUserDefaultsGradeCategoryKey: category]
        }

        NSUserDefaults.standardUserDefaults().setObject(systemKeys, forKey: kNSUserDefaultsSelectedGradeSystems)
        NSUserDefaults.standardUserDefaults().synchronize()

        NSNotificationCenter.defaultCenter().postNotificationName(kNSUserDefaultsSystemSelectionChangedNotification, object: nil)
    }

    func addSelectedGradeSystem(gradeSystem:GradeSystem) {
        var gradeSystems = selectedGradeSystems()
        gradeSystems.append(gradeSystem)
        setSelectedGradeSystems(gradeSystems)
    }

    func removeSelectedGradeSystem(gradeSystemToRemove: GradeSystem) {
        var gradeSystems = selectedGradeSystems()
        gradeSystems = gradeSystems.filter { (gradeSystem: GradeSystem) -> Bool in
            return gradeSystem != gradeSystemToRemove
        }
        setSelectedGradeSystems(gradeSystems)
    }

    func selectedGradeSystems() -> [GradeSystem] {
        let globalSystemTable = GradeSystemTable.sharedInstance

        if let systemKeys = NSUserDefaults.standardUserDefaults().arrayForKey(kNSUserDefaultsSelectedGradeSystems) as? [[String:String]] {
            return systemKeys.reduce([], combine: { (var gradeSystems: [GradeSystem], dict: [String : String]) -> [GradeSystem] in
                let name = dict[kNSUserDefaultsGradeNameKey] ?? ""
                let category = dict[kNSUserDefaultsGradeCategoryKey] ?? ""

                if let gradeSystem = globalSystemTable.gradeSystemForName(name, category: category) {
                    gradeSystems.append(gradeSystem)
                }

                return gradeSystems
            })
        }

        return kNSUserDefaultsDefaultGradeSystem()
    }
}