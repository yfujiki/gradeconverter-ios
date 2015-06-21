//
//  GradingTableTest.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import XCTest

class GradingTableTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testNames() {
        let table = GradingTable()

        XCTAssertEqual(16, table.names().count, "Total number of table columns should be 16.")
        XCTAssertEqual("Brazil", table.names()[0], "System name should be correct.")
        XCTAssertEqual("Brazil", table.names()[1], "System name should be correct.")
        XCTAssertEqual("British Adjectival", table.names()[2], "System name should be correct.")
        XCTAssertEqual("British Technical", table.names()[3], "System name should be correct.")
        XCTAssertEqual("Ewbank AUS/NZ", table.names()[4], "System name should be correct.")
        XCTAssertEqual("Ewbank South Africa", table.names()[5], "System name should be correct.")
        XCTAssertEqual("Fontainebleu", table.names()[6], "System name should be correct.")
        XCTAssertEqual("French", table.names()[7], "System name should be correct.")
        XCTAssertEqual("Hueco", table.names()[8], "System name should be correct.")
        XCTAssertEqual("Nordic FIN", table.names()[9], "System name should be correct.")
        XCTAssertEqual("Nordic SWE/NOR", table.names()[10], "System name should be correct.")
        XCTAssertEqual("Ogawayama", table.names()[11], "System name should be correct.")
        XCTAssertEqual("Saxon", table.names()[12], "System name should be correct.")
        XCTAssertEqual("Toyota", table.names()[13], "System name should be correct.")
        XCTAssertEqual("UIAA", table.names()[14], "System name should be correct.")
        XCTAssertEqual("Yosemite Decimal System", table.names()[15], "System name should be correct.")
    }
}
