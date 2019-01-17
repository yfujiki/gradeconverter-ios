//
//  NSUserDefaults+Additions.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import Foundation

let kNSUserDefaultsCurrentIndexes = "com.yfujiki.gradeConverter.currentIndexes"
let kNSUserDefaultsSelectedGradeSystems = "com.yfujiki.gradeConverter.selectedGradeSystems"
let kNSUserDefaultsBaseSystem = "com.yfujiki.gradeConverter.baseSystem"
let kNSUserDefaultsGradeNameKey = "gradeName"
let kNSUserDefaultsGradeCategoryKey = "gradeCategory"

let kNSUserDefaultsDefaultIndexes = [Int(17)]

var kNSUserDefaultsDefaultGradeSystem: [GradeSystem] {
    if CurrentCountry() == .jp {
        return [
            GradeSystemTable.sharedInstance.gradeSystemForName("Ogawayama", category: "Boulder")!,
            GradeSystemTable.sharedInstance.gradeSystemForName("Hueco", category: "Boulder")!,
            GradeSystemTable.sharedInstance.gradeSystemForName("Yosemite Decimal System", category: "Sports")!,
        ]
    }

    // US and everything else
    return [
        GradeSystemTable.sharedInstance.gradeSystemForName("Hueco", category: "Boulder")!,
        GradeSystemTable.sharedInstance.gradeSystemForName("Fontainebleu", category: "Boulder")!,
        GradeSystemTable.sharedInstance.gradeSystemForName("Yosemite Decimal System", category: "Sports")!,
        GradeSystemTable.sharedInstance.gradeSystemForName("French", category: "Sports")!,
    ]
}

extension UserDefaults {

    func setCurrentIndexes(_ indexes: [Int]) {
        set(indexes, forKey: kNSUserDefaultsCurrentIndexes)
        synchronize()

        let notifcationName = NotificationTypes.currentIndexChangedNotification.notificationName()
        let userInfo = [NotificationTypes.NotificationKeys.currentIndexesKey: indexes]
        NotificationCenter.default.post(name: notifcationName, object: self, userInfo: userInfo)
    }

    func currentIndexes() -> [Int] {
        let indexes = UserDefaults.standard.array(forKey: kNSUserDefaultsCurrentIndexes) as? [Int]

        return indexes ?? kNSUserDefaultsDefaultIndexes
    }

    func setSelectedGradeSystems(_ gradeSystems: [GradeSystem]) {
        let systemKeys = gradeSystems.map { (gradeSystem: GradeSystem) -> [String: String] in
            let name = gradeSystem.name
            let category = gradeSystem.category
            return [kNSUserDefaultsGradeNameKey: name, kNSUserDefaultsGradeCategoryKey: category]
        }

        set(systemKeys, forKey: kNSUserDefaultsSelectedGradeSystems)
        synchronize()

        let notifcationName = NotificationTypes.systemSelectionChangedNotification.notificationName()
        let userInfo = [NotificationTypes.NotificationKeys.selectedSystemsKey: gradeSystems]
        NotificationCenter.default.post(name: notifcationName, object: self, userInfo: userInfo)
    }

    func addSelectedGradeSystem(_ gradeSystem: GradeSystem) {
        var gradeSystems = selectedGradeSystems()
        gradeSystems.append(gradeSystem)
        setSelectedGradeSystems(gradeSystems)
    }

    func removeSelectedGradeSystem(_ gradeSystemToRemove: GradeSystem) {
        var gradeSystems = selectedGradeSystems()
        gradeSystems = gradeSystems.filter { (gradeSystem: GradeSystem) -> Bool in
            return gradeSystem != gradeSystemToRemove
        }
        setSelectedGradeSystems(gradeSystems)
    }

    func selectedGradeSystems() -> [GradeSystem] {
        let globalSystemTable = GradeSystemTable.sharedInstance

        if let systemKeys = UserDefaults.standard.array(forKey: kNSUserDefaultsSelectedGradeSystems) as? [[String: String]] {
            return systemKeys.reduce([], { (tmp: [GradeSystem], dict: [String: String]) -> [GradeSystem] in
                var results = tmp
                let name = dict[kNSUserDefaultsGradeNameKey] ?? ""
                let category = dict[kNSUserDefaultsGradeCategoryKey] ?? ""

                if let gradeSystem = globalSystemTable.gradeSystemForName(name, category: category) {
                    results.append(gradeSystem)
                }

                return results
            })
        }

        return kNSUserDefaultsDefaultGradeSystem
    }

    func selectedGradeSystemNamesCSV() -> String {
        return selectedGradeSystems().reduce("") { (intermediate, system) -> String in
            if intermediate.utf8.count == 0 {
                return system.name
            } else {
                return intermediate + ", " + system.name
            }
        }
    }

    func baseSystem() -> GradeSystem? {
        let key = value(forKey: kNSUserDefaultsBaseSystem) as? String

        guard let array = key?.split(separator: "-"), array.count == 2 else {
            return nil
        }
        let name = String(array.first!)
        let category = String(array.last!)

        return GradeSystemTable.sharedInstance.gradeSystemForName(name, category: category)
    }

    func setBaseSystem(gradeSystem: GradeSystem?) {
        set(gradeSystem?.key, forKey: kNSUserDefaultsBaseSystem)
        synchronize()

        let notifcationName = NotificationTypes.baseSystemChangedNotification.notificationName()
        let userInfo = gradeSystem == nil ? [:] : [NotificationTypes.NotificationKeys.baseSystemKey: gradeSystem]
        NotificationCenter.default.post(name: notifcationName, object: self, userInfo: userInfo)
    }
}
