//
//  LocalStorageImpl.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/12/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation

class LocalStorageImpl: LocalStorage {
    func setCurrentIndexes(_ indexes: [Int]) {
        UserDefaults.standard.setCurrentIndexes(indexes)
    }

    func currentIndexes() -> [Int] {
        return UserDefaults.standard.currentIndexes()
    }

    func setSelectedGradeSystems(_ gradeSystems: [GradeSystem]) {
        UserDefaults.standard.setSelectedGradeSystems(gradeSystems)
    }

    func addSelectedGradeSystem(_ gradeSystem: GradeSystem) {
        UserDefaults.standard.addSelectedGradeSystem(gradeSystem)
    }

    func removeSelectedGradeSystem(_ gradeSystemToRemove: GradeSystem) {
        UserDefaults.standard.removeSelectedGradeSystem(gradeSystemToRemove)
    }

    func selectedGradeSystems() -> [GradeSystem] {
        return UserDefaults.standard.selectedGradeSystems()
    }

    func selectedGradeSystemNamesCSV() -> String {
        return UserDefaults.standard.selectedGradeSystemNamesCSV()
    }
}
