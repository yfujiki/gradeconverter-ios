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
        XCTAssertEqual(0, NSUserDefaults.standardUserDefaults().selectedGradeSystems().count, "Initially, selected grade systems should be empty.")

        let gradeSystem = GradeSystem(name: "Yosemite Decimal Scale", category:"Sports", locales: [], grades: [])

        NSUserDefaults.standardUserDefaults().setSelectedGradeSystems([gradeSystem])

//        TODO : Check
//        XCTAssertEqual([gradeSystem], NSUserDefaults.standardUserDefaults().selectedGradeSystems(), "The results should represent proper additions")
    }
}
