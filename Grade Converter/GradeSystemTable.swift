//
//  GradeSystemTable.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import Foundation

struct GradeSystem {
    var name: String
    var category: String
    var locales: [String]
    var grades: [String] = [String]()

    var key: String {
        return "\(name)-\(category)"
    }

    mutating func addGrade(grade: String) {
        grades.append(grade)
    }

    func gradeAtIndex(index: Int) -> String {
        var convertedIndex = index
        if convertedIndex < 0 {
            convertedIndex = 0
        }
        if convertedIndex >= grades.count {
            convertedIndex = grades.count - 1
        }

        return grades[convertedIndex]
    }

    func indexesForGrade(grade: String) -> [Int] {
        var indexes = [Int]()
        for var i=0; i<grades.count; i++ {
            if grades[i] == grade {
                indexes.append(i)
            }
        }

        return indexes
    }
}

struct GradeSystemTable {

    private static var kFileName: String {
        return NSBundle.mainBundle().pathForResource("GradeSystemTable", ofType: "csv")!
    }

    // Dictionary where key => grade system name, value => array of grade number
    private var tableBody: [String: GradeSystem] = [:]

    init() {
        var error: NSError?

        if var contents = NSString(contentsOfFile: self.dynamicType.kFileName, encoding: NSUTF8StringEncoding, error: &error) {
            let lines = contents.componentsSeparatedByString("\n") as! [String]

            let names = lines[0].componentsSeparatedByString(",") as [String]
            let categories = lines[1].componentsSeparatedByString(",") as [String]
            let locales = lines[2].componentsSeparatedByString(",") as [String]
            let arrayOfGrades = lines[3..<lines.count]

            for var i = 0; i < names.count; i++ {
                let gradeSystem = GradeSystem(name: names[i], category: categories[i], locales: [locales[i]], grades: [String]())
                tableBody[gradeSystem.key] = gradeSystem
            }

            for grades in arrayOfGrades {
                let gradesOfSameLevel = grades.componentsSeparatedByString(",") as [String]

                for var i=0; i<names.count; i++ {
                    let key = "\(names[i])-\(categories[i])"
                    tableBody[key]?.addGrade(gradesOfSameLevel[i])
                }
            }

        } else if error != nil {
            NSLog("Failed to read contents from file \(self.dynamicType.kFileName) : \(error?.debugDescription)")
            abort()
        }
    }

    func names() -> [String] {
        return map(tableBody, { (key: String, gradeSystem: GradeSystem) -> String in
            gradeSystem.name
        }).sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending}
    }

    func gradeSystemForName(name:String, category:String) -> GradeSystem? {
        let key = "\(name)-\(category)"
        return tableBody[key]
    }
}