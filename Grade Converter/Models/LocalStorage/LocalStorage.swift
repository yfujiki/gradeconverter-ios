//
//  LocalStorageInterface.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/12/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation

protocol LocalStorage {

    func setCurrentIndexes(_ indexes: [Int])

    func currentIndexes() -> [Int]

    func setSelectedGradeSystems(_ gradeSystems: [GradeSystem])

    func addSelectedGradeSystem(_ gradeSystem: GradeSystem)

    func removeSelectedGradeSystem(_ gradeSystemToRemove: GradeSystem)

    func selectedGradeSystems() -> [GradeSystem]

    func selectedGradeSystemNamesCSV() -> String

    func unselectedGradeSystems() -> [GradeSystem]

    func setBaseSystem(_ gradeSystem: GradeSystem)

    func baseSystem() -> GradeSystem?

    func isBaseSystem(_ gradeSystem: GradeSystem?) -> Bool
}
