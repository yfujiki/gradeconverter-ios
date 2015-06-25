//
//  NSUserDefaultsTest.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/24/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import XCTest

class NSUserDefaultsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {

        NSUserDefaults.standardUserDefaults().removeObjectForKey(kNSUserDefaultsCurrentIndexes)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kNSUserDefaultsSelectedGradeSystems)

        super.tearDown()
    }

    func testCurrentIndexes() {
        XCTAssertEqual(kNSUserDefaultsDefaultIndexes, NSUserDefaults.standardUserDefaults().currentIndexes(), "Initially, current should be default indexes.")

        var currentIndexes = NSUserDefaults.standardUserDefaults().currentIndexes()
        currentIndexes.append(19)
        currentIndexes.append(20)

        NSUserDefaults.standardUserDefaults().setCurrentIndexes(currentIndexes)

        var expectedIndexes = kNSUserDefaultsDefaultIndexes
        expectedIndexes.append(19)
        expectedIndexes.append(20)

        XCTAssertEqual(expectedIndexes, currentIndexes, "The results should represents proper additions.")
    }

    func testSelectedGradeSystems() {
        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystems, NSUserDefaults.standardUserDefaults().selectedGradeSystems(), "Initially, selected grade systems should be default.")

        let gradeSystem1 = GradeSystem(name: "Yosemite Decimal System", category:"Sports", locales: [], grades: [])
        NSUserDefaults.standardUserDefaults().setSelectedGradeSystems([gradeSystem1])
        XCTAssertEqual([gradeSystem1], NSUserDefaults.standardUserDefaults().selectedGradeSystems(), "The results should represent proper additions")

        let gradeSystem2 = GradeSystem(name: "Hueco", category:"Boulder", locales: [], grades: [])
        NSUserDefaults.standardUserDefaults().addSelectedGradeSystem(gradeSystem2)
        XCTAssertEqual([gradeSystem1, gradeSystem2], NSUserDefaults.standardUserDefaults().selectedGradeSystems(), "The results should represent proper additions")

        NSUserDefaults.standardUserDefaults().removeSelectedGradeSystem(gradeSystem1)
        XCTAssertEqual([gradeSystem2], NSUserDefaults.standardUserDefaults().selectedGradeSystems(), "The results should represent proper removals")
    }
}
