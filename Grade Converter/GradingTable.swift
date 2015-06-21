//
//  GradingTable.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import Foundation

struct GradeSystem {
    private var name: String
    private var category: String
    private var locales: [String]
    private var grades: [String] = [String]()

    var key: String {
        return "\(name)-\(category)"
    }

    mutating func addGrade(grade: String) {
        grades.append(grade)
    }
}

struct GradingTable {

    private static var kFileName: String {
        return NSBundle.mainBundle().pathForResource("GradingTable", ofType: "csv")!
    }

    // Dictionary where key => grade system name, value => array of grade number
    private var gradeTable: [String: GradeSystem] = [:]

    init() {
        var error: NSError?

        if var contents = NSString(contentsOfFile: self.dynamicType.kFileName, encoding: NSUTF8StringEncoding, error: &error) {
            let lines = contents.componentsSeparatedByString("\n") as! [String]

            let names = lines[0].componentsSeparatedByString(",") as [String]
            let categories = lines[1].componentsSeparatedByString(",") as [String]
            let locales = lines[2].componentsSeparatedByString(",") as [String]
            let grades = lines[3..<lines.count]

            for var i = 0; i < names.count; i++ {
                let system = GradeSystem(name: names[i], category: categories[i], locales: [locales[i]], grades: [String]())
                gradeTable[system.key] = system
            }

            for grade in grades {
                let gradesOfSameLevel = grade.componentsSeparatedByString(",") as [String]

                for var i=0; i<names.count; i++ {
                    let key = "\(names[i])-\(categories[i])"
                    gradeTable[key]?.addGrade(gradesOfSameLevel[i])
                }
            }

        } else if error != nil {
            NSLog("Failed to read contents from file \(self.dynamicType.kFileName) : \(error?.debugDescription)")
            abort()
        }
    }

    func names() -> [String] {
        return map(gradeTable, { (key: String, system: GradeSystem) -> String in
            system.name
        }).sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending}
    }
}