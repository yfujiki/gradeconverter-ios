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
    private var grades: [String]
}

struct GradingTable {

    private static var kFileName: String {
        return NSBundle.pathForResource("GradingTable", ofType: "csv", inDirectory: "")!
    }

    // Dictionary where key => grade system name, value => array of grade number
    private var gradeTable: [String: GradeSystem] = [:]

    init() {
        var error: NSError?

        if var contents = NSString(contentsOfFile: self.dynamicType.kFileName, encoding: NSUTF8StringEncoding, error: &error) {
            let gradeSystems = contents.componentsSeparatedByString("\n") as! [String]
            gradeTable = gradeSystems.reduce([:]) {
                (var table:[String: GradeSystem], line: String) -> [String: GradeSystem] in
                let words = line.componentsSeparatedByString(",")
                let name = words[0]
                let category = words[1]
                let locales = words[2].componentsSeparatedByString(" ")
                let grades = [String](words[2..<words.count])

                table[name] = GradeSystem(name: name, category: category, locales: locales, grades: grades)

                return table
            }

        } else if error != nil {
            NSLog("Failed to read contents from file \(self.dynamicType.kFileName) : \(error?.debugDescription)")
            abort()
        }
    }
}