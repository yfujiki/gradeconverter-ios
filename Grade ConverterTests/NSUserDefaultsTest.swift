//
//  NSUserDefaultsTest.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import XCTest
@testable import Grade_Converter

class NSUserDefaultsTest: XCTestCase {

    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "UnitTest")
        LocalStorageImpl(userDefaults: userDefaults).injectToApp()
    }

    override func tearDown() {
        userDefaults.removeSuite(named: "UnitTest")
        super.tearDown()
    }

    func testCurrentIndexes() {
        XCTAssertEqual(kNSUserDefaultsDefaultIndexes, userDefaults.currentIndexes(), "Initially, current should be default indexes.")

        var currentIndexes = userDefaults.currentIndexes()
        currentIndexes.append(19)
        currentIndexes.append(20)

        userDefaults.setCurrentIndexes(currentIndexes)

        var expectedIndexes = kNSUserDefaultsDefaultIndexes
        expectedIndexes.append(19)
        expectedIndexes.append(20)

        XCTAssertEqual(expectedIndexes, currentIndexes, "The results should represents proper additions.")
    }

    func testSelectedGradeSystems() {
        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem, userDefaults.selectedGradeSystems(), "Initially, selected grade systems should be default.")

        let gradeSystem1 = GradeSystem(name: "Yosemite Decimal System", category: "Sports", locales: [], grades: [])
        userDefaults.setSelectedGradeSystems([gradeSystem1])
        XCTAssertEqual([gradeSystem1], userDefaults.selectedGradeSystems(), "The results should represent proper additions")

        let gradeSystem2 = GradeSystem(name: "Hueco", category: "Boulder", locales: [], grades: [])
        userDefaults.addSelectedGradeSystem(gradeSystem2)
        XCTAssertEqual([gradeSystem1, gradeSystem2], userDefaults.selectedGradeSystems(), "The results should represent proper additions")

        userDefaults.removeSelectedGradeSystem(gradeSystem1)
        XCTAssertEqual([gradeSystem2], userDefaults.selectedGradeSystems(), "The results should represent proper removals")
    }
}
