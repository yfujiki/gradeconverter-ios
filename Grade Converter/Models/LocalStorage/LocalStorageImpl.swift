//
//  LocalStorageImpl.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/12/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation

class LocalStorageStandardImpl: LocalStorageImpl {
    init() {
        super.init(userDefaults: UserDefaults.standard)
    }
}

class LocalStorageImpl: LocalStorage {
    private var userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func setCurrentIndexes(_ indexes: [Int]) {
        userDefaults.setCurrentIndexes(indexes)
    }

    func currentIndexes() -> [Int] {
        return userDefaults.currentIndexes()
    }

    func setSelectedGradeSystems(_ gradeSystems: [GradeSystem]) {
        userDefaults.setSelectedGradeSystems(gradeSystems)
    }

    func addSelectedGradeSystem(_ gradeSystem: GradeSystem) {
        userDefaults.addSelectedGradeSystem(gradeSystem)
    }

    func removeSelectedGradeSystem(_ gradeSystemToRemove: GradeSystem) {
        userDefaults.removeSelectedGradeSystem(gradeSystemToRemove)
    }

    func selectedGradeSystems() -> [GradeSystem] {
        return userDefaults.selectedGradeSystems()
    }

    func selectedGradeSystemNamesCSV() -> String {
        return userDefaults.selectedGradeSystemNamesCSV()
    }

    func unselectedGradeSystems() -> [GradeSystem] {
        let selectedGradeSystems = self.selectedGradeSystems()
        return GradeSystemTable.sharedInstance.gradeSystems().filter { (gradeSystem) -> Bool in
            !selectedGradeSystems.contains(gradeSystem)
        }
    }

    func setBaseSystem(_ gradeSystem: GradeSystem) {
        userDefaults.setBaseSystem(gradeSystem: gradeSystem)
    }

    func baseSystem() -> GradeSystem? {
        return userDefaults.baseSystem()
    }

    func isBaseSystem(_ gradeSystem: GradeSystem?) -> Bool {
        if gradeSystem == nil {
            return false
        }

        return userDefaults.baseSystem() == gradeSystem
    }
}
