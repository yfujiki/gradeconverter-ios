//
//  FastlaneSnapshotUITests.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/15/16.
//  Copyright © 2016 Responsive Bytes. All rights reserved.
//

import XCTest

class FastlaneSnapshotUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launchEnvironment = ["UITEST": "true"]
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMainScreen() {
        let tablesQuery = XCUIApplication().tables
        tablesQuery.cells.allElementsBoundByIndex.first!.buttons["right arrow"].tap()

        // Check Point : number name of the snapshot
        snapshot("0Main")

        // Check Point : bring back the state
        tablesQuery.cells.allElementsBoundByIndex.first!.buttons["left arrow"].tap()
    }

    func testMoreScreen() {
        let app = XCUIApplication()
        app.tables.cells.allElementsBoundByIndex.last!.tap()

        snapshot("1Add")
    }

    func testEditScreen() {
        let app = XCUIApplication()
        app.navigationBars["Main Navigation Bar"].buttons["Edit Button"].tap()

        snapshot("2Edit")
    }
}
