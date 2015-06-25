//
//  GradeSystemTableTest.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import XCTest

class GradeSystemTableTest: XCTestCase {

    var table: GradeSystemTable!

    override func setUp() {
        table = GradeSystemTable()

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testNamesAndCategories() {
        XCTAssertEqual(16, table.namesAndCategories().count, "Total number of table columns should be 16.")
        XCTAssertEqual("Brazil", table.namesAndCategories()[0].0, "System name should be correct.")
        XCTAssertEqual("British Adjectival", table.namesAndCategories()[1].0, "System name should be correct.")
        XCTAssertEqual("British Technical", table.namesAndCategories()[2].0, "System name should be correct.")
        XCTAssertEqual("Ewbank AUS/NZ", table.namesAndCategories()[3].0, "System name should be correct.")
        XCTAssertEqual("Ewbank South Africa", table.namesAndCategories()[4].0, "System name should be correct.")
        XCTAssertEqual("French", table.namesAndCategories()[5].0, "System name should be correct.")
        XCTAssertEqual("Nordic FIN", table.namesAndCategories()[6].0, "System name should be correct.")
        XCTAssertEqual("Nordic SWE/NOR", table.namesAndCategories()[7].0, "System name should be correct.")
        XCTAssertEqual("Saxon", table.namesAndCategories()[8].0, "System name should be correct.")
        XCTAssertEqual("UIAA", table.namesAndCategories()[9].0, "System name should be correct.")
        XCTAssertEqual("Yosemite Decimal System", table.namesAndCategories()[10].0, "System name should be correct.")
        XCTAssertEqual("Brazil", table.namesAndCategories()[11].0, "System name should be correct.")
        XCTAssertEqual("Fontainebleu", table.namesAndCategories()[12].0, "System name should be correct.")
        XCTAssertEqual("Hueco", table.namesAndCategories()[13].0, "System name should be correct.")
        XCTAssertEqual("Ogawayama", table.namesAndCategories()[14].0, "System name should be correct.")
        XCTAssertEqual("Toyota", table.namesAndCategories()[15].0, "System name should be correct.")

        XCTAssertEqual("Brazil", table.namesAndCategories()[0].0, "System name should be correct.")
        XCTAssertEqual("British Adjectival", table.namesAndCategories()[1].0, "System name should be correct.")
        XCTAssertEqual("British Technical", table.namesAndCategories()[2].0, "System name should be correct.")
        XCTAssertEqual("Ewbank AUS/NZ", table.namesAndCategories()[3].0, "System name should be correct.")
        XCTAssertEqual("Ewbank South Africa", table.namesAndCategories()[4].0, "System name should be correct.")
        XCTAssertEqual("French", table.namesAndCategories()[5].0, "System name should be correct.")
        XCTAssertEqual("Nordic FIN", table.namesAndCategories()[6].0, "System name should be correct.")
        XCTAssertEqual("Nordic SWE/NOR", table.namesAndCategories()[7].0, "System name should be correct.")
        XCTAssertEqual("Saxon", table.namesAndCategories()[8].0, "System name should be correct.")
        XCTAssertEqual("UIAA", table.namesAndCategories()[9].0, "System name should be correct.")
        XCTAssertEqual("Yosemite Decimal System", table.namesAndCategories()[10].0, "System name should be correct.")
        XCTAssertEqual("Brazil", table.namesAndCategories()[11].0, "System name should be correct.")
        XCTAssertEqual("Fontainebleu", table.namesAndCategories()[12].0, "System name should be correct.")
        XCTAssertEqual("Hueco", table.namesAndCategories()[13].0, "System name should be correct.")
        XCTAssertEqual("Ogawayama", table.namesAndCategories()[14].0, "System name should be correct.")
        XCTAssertEqual("Toyota", table.namesAndCategories()[15].0, "System name should be correct.")
}

    func testGradeSystemForNameCategory() {
        XCTAssertEqual("Brazil", table.gradeSystemForName("Brazil", category: "Sports")!.name, "Name should match.")
        XCTAssertEqual("Sports", table.gradeSystemForName("Brazil", category: "Sports")!.category, "Category should match.")
        XCTAssertEqual("Brazil", table.gradeSystemForName("Brazil", category: "Boulder")!.name, "Name should match.")
        XCTAssertEqual("Boulder", table.gradeSystemForName("Brazil", category: "Boulder")!.category, "Category should match.")
        XCTAssertEqual("Yosemite Decimal System", table.gradeSystemForName("Yosemite Decimal System", category: "Sports")!.name, "Name should match.")
        XCTAssertEqual("Sports", table.gradeSystemForName("Yosemite Decimal System", category: "Sports")!.category, "Category should match.")
        XCTAssertTrue(nil == table.gradeSystemForName("Hueco", category: "Sports"), "Returns nil for non existing combo.")
    }

    func testGradeAtIndex() {
        let yosemiteGrade = table.gradeSystemForName("Yosemite Decimal System", category: "Sports")!

        XCTAssertEqual("5.1", yosemiteGrade.gradeAtIndex(0, higher: false), "Lowest grade should be 5.1.")
        XCTAssertEqual("5.15c", yosemiteGrade.gradeAtIndex(yosemiteGrade.grades.count - 1, higher: true), "Highest grade should be 5.15c.") // TODO : that's a little bit weak
    }

    func testGradeAtIndexes() {
        let yosemiteGrade = table.gradeSystemForName("Yosemite Decimal System", category: "Sports")!

        XCTAssertEqual("5.1/5.2", yosemiteGrade.gradeAtIndexes([0, 1, 2]), "Grade range should match")
        XCTAssertEqual("5.10d/5.11b", yosemiteGrade.gradeAtIndexes([20, 21, 22, 23]), "Grade ranged should match")
        XCTAssertEqual("5.10d/5.11b", yosemiteGrade.gradeAtIndexes([20, 21, 22]), "Grade ranged should match")
        XCTAssertEqual("5.11a/5.11b", yosemiteGrade.gradeAtIndexes([22, 23]), "Grade ranged should match")
    }

    func textIndexesForGrade() {
        let huecoGrade = table.gradeSystemForName("Hueco", category: "Boulder")!

        XCTAssertEqual([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], huecoGrade.indexesForGrade("VB"), "VB should cover wide range.")
        XCTAssertEqual([29, 30], huecoGrade.indexesForGrade("V6"), "V6 should cover 2 slots.")
    }

    func testLowerHigherGradeFromIndexes() {
        let huecoGrade = table.gradeSystemForName("Hueco", category: "Boulder")!

        XCTAssertEqual("VB", huecoGrade.lowerGradeFromIndexes([15, 16]), "Lower grade of V0 should be VB.")
        XCTAssertEqual("V0+", huecoGrade.higherGradeFromIndexes([15, 16]), "Higher grade of V0 should be V0+.")

        XCTAssertEqual("V0", huecoGrade.lowerGradeFromIndexes([15, 19]), "Lower grade of V0-V1 should be V1.")
        XCTAssertEqual("V1", huecoGrade.higherGradeFromIndexes([15, 19]), "Higher grade of V0-V1 should be V1.")

        XCTAssertEqual("V3", huecoGrade.lowerGradeFromIndexes([21, 24]), "Lower grade of V3-V4 should be V3.")
        XCTAssertEqual("V4", huecoGrade.higherGradeFromIndexes([21, 24]), "Higher grade of V3-V4 should be V4.")

        XCTAssertEqual("V3", huecoGrade.lowerGradeFromIndexes([21, 25]), "Lower grade of V3-V4 should be V3.")
        XCTAssertEqual("V5", huecoGrade.higherGradeFromIndexes([21, 25]), "Higher grade of V3-V4 should be V4.")
    }

    func testGradeSystemsForLocale() {
        let usLocale = "en-US"

        let gradeSystemsForUS = table.gradeSystemsForLocale(usLocale)
        XCTAssertEqual(2, gradeSystemsForUS.count, "US locale should have YDS and Hueco.")
        XCTAssertEqual(gradeSystemsForUS[0].name, "Hueco", "First grade system for US should be Hueco.")
        XCTAssertEqual(gradeSystemsForUS[1].name, "Yosemite Decimal System", "Second grade system for US should be YDS.")

        let jpLocale = "ja-JP"
        let gradeSystemsForJapan = table.gradeSystemsForLocale(jpLocale)
        XCTAssertEqual(2, gradeSystemsForJapan.count, "Japan locale should have Toyota and Ogawayama.")
        XCTAssertEqual(gradeSystemsForJapan[0].name, "Ogawayama", "First grade system for Japan should be Ogawayama.")
        XCTAssertEqual(gradeSystemsForJapan[1].name, "Toyota", "Second grade system for Japan should be Toyota.")
    }
}
