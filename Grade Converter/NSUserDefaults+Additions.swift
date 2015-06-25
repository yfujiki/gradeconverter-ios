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

let kNSUserDefaultsDefaultIndexes = [Int(10)]
let kNSUserDefaultsDefaultGradeSystems = [
    GradeSystemTable().gradeSystemForName("Yosemite Decimal System", category: "Sports")!,
    GradeSystemTable().gradeSystemForName("Hueco", category: "Boulder")!
] // TODO : depends on locales

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
    }

    func selectedGradeSystems() -> [GradeSystem] {
        let globalSystemTable = GradeSystemTable()

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

        return kNSUserDefaultsDefaultGradeSystems
    }
}