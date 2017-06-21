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

    override func setUp() {
        super.setUp()

        UserDefaults.standard.removeObject(forKey: kNSUserDefaultsCurrentIndexes)
        UserDefaults.standard.removeObject(forKey: kNSUserDefaultsSelectedGradeSystems)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: kNSUserDefaultsCurrentIndexes)
        UserDefaults.standard.removeObject(forKey: kNSUserDefaultsSelectedGradeSystems)

        super.tearDown()
    }

    func testCurrentIndexes() {
        XCTAssertEqual(kNSUserDefaultsDefaultIndexes, UserDefaults.standard.currentIndexes(), "Initially, current should be default indexes.")

        var currentIndexes = UserDefaults.standard.currentIndexes()
        currentIndexes.append(19)
        currentIndexes.append(20)

        UserDefaults.standard.setCurrentIndexes(currentIndexes)

        var expectedIndexes = kNSUserDefaultsDefaultIndexes
        expectedIndexes.append(19)
        expectedIndexes.append(20)

        XCTAssertEqual(expectedIndexes, currentIndexes, "The results should represents proper additions.")
    }

    func testSelectedGradeSystems() {
        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem, UserDefaults.standard.selectedGradeSystems(), "Initially, selected grade systems should be default.")

        let gradeSystem1 = GradeSystem(name: "Yosemite Decimal System", category: "Sports", locales: [], grades: [])
        UserDefaults.standard.setSelectedGradeSystems([gradeSystem1])
        XCTAssertEqual([gradeSystem1], UserDefaults.standard.selectedGradeSystems(), "The results should represent proper additions")

        let gradeSystem2 = GradeSystem(name: "Hueco", category: "Boulder", locales: [], grades: [])
        UserDefaults.standard.addSelectedGradeSystem(gradeSystem2)
        XCTAssertEqual([gradeSystem1, gradeSystem2], UserDefaults.standard.selectedGradeSystems(), "The results should represent proper additions")

        UserDefaults.standard.removeSelectedGradeSystem(gradeSystem1)
        XCTAssertEqual([gradeSystem2], UserDefaults.standard.selectedGradeSystems(), "The results should represent proper removals")
    }
}
