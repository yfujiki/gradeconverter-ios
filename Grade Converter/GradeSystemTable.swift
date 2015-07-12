//
//  GradeSystemTable.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import Foundation

struct GradeSystem : Equatable {
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

    func gradeAtIndex(index: Int, higher: Bool) -> String {
        var convertedIndex = index
        if convertedIndex < 0 {
            convertedIndex = 0
        }
        if convertedIndex >= grades.count {
            convertedIndex = grades.count - 1
        }

        var grade = grades[convertedIndex]

        if grade.characters.count == 0 {
            if higher {
                if let higherGrade = higherGradeAtIndex(index) {
                    grade = higherGrade
                } else {
                    grade = lowerGradeAtIndex(index) ?? ""
                }
            } else {
                if let lowerGrade = lowerGradeAtIndex(index) {
                    grade = lowerGrade
                } else {
                    grade = higherGradeAtIndex(index) ?? ""
                }
            }
        }

        assert(grade.characters.count > 0, "Grade should have something at this point.")

        return grade
    }

    func gradeAtIndexes(indexes: [Int]) -> String {
        let sortedIndexes = indexes.sort(<=)

        let lowGrade = gradeAtIndex(sortedIndexes[0], higher: false)
        let highGrade = gradeAtIndex(sortedIndexes[indexes.count - 1], higher: true)

        if lowGrade == highGrade {
            return lowGrade
        } else {
            return "\(lowGrade)/\(highGrade)"
        }
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

    private func higherGradeAtIndex(index: Int) -> String? {
        for var i=index; i<grades.count; i++ {
            if grades[i].characters.count > 0 {
                return grades[i]

            }
        }
        return nil
    }

    private func lowerGradeAtIndex(index: Int) -> String? {
        for var i=index; i>=0; i-- {
            if grades[i].characters.count > 0 {
                return grades[i]
            }
        }
        return nil
    }
    
    func higherGradeFromIndexes(indexes:[Int]) -> String? {
        return nextGradeFromIndexes(indexes, higher: true)
    }

    func lowerGradeFromIndexes(indexes:[Int]) -> String? {
        return nextGradeFromIndexes(indexes, higher: false)
    }

    private func nextGradeFromIndexes(indexes:[Int], higher: Bool) -> String? {
        let sortedIndexes = indexes.sort { $0 <= $1 }

        let lowGrade = gradeAtIndex(sortedIndexes[0], higher:false)
        let highGrade = gradeAtIndex(sortedIndexes[indexes.count - 1], higher:true)

        var nextGrade: String?

        if lowGrade == highGrade {
            if higher {
                for var i=sortedIndexes[indexes.count - 1]; i<grades.count; i++ {
                    if grades[i].characters.count > 0 && grades[i] != highGrade {
                        nextGrade = grades[i]
                        break
                    }
                }
            } else {
                for var i=sortedIndexes[0]; i>=0; i-- {
                    if grades[i].characters.count > 0 && grades[i] != lowGrade {
                        nextGrade = grades[i]
                        break
                    }
                }
            }
        } else {
            if higher {
                nextGrade = highGrade
            } else {
                nextGrade = lowGrade
            }
        }

        return nextGrade
    }
}

func == (this: GradeSystem, that: GradeSystem) -> Bool {
    return this.name == that.name && this.category == that.category
}

struct GradeSystemTable {

    private static var kFileName: String {
        return NSBundle.mainBundle().pathForResource("GradeSystemTable", ofType: "csv")!
    }

    // Dictionary where key => grade system name, value => array of grade number
    private var tableBody: [String: GradeSystem] = [:]

    init() {
        var error: NSError?

        do {
            let contents = try NSString(contentsOfFile: self.dynamicType.kFileName, encoding: NSUTF8StringEncoding)
            let lines = contents.componentsSeparatedByString("\n") as [String]

            let names = lines[0].componentsSeparatedByString(",") as [String]
            let categories = lines[1].componentsSeparatedByString(",") as [String]
            let arrayOfLocales = lines[2].componentsSeparatedByString(",") as [String]
            let arrayOfGrades = lines[3..<lines.count]

            for var i = 0; i < names.count; i++ {
                let locales = arrayOfLocales[i].componentsSeparatedByString(" ")
                let gradeSystem = GradeSystem(name: names[i], category: categories[i], locales: locales, grades: [String]())
                tableBody[gradeSystem.key] = gradeSystem
            }

            for grades in arrayOfGrades {
                let gradesOfSameLevel = grades.componentsSeparatedByString(",") as [String]

                for var i=0; i<names.count; i++ {
                    let key = "\(names[i])-\(categories[i])"
                    tableBody[key]?.addGrade(gradesOfSameLevel[i])
                }
            }

        } catch let error1 as NSError {
            error = error1
            if error != nil {
                NSLog("Failed to read contents from file \(self.dynamicType.kFileName) : \(error?.debugDescription)")
                abort()
            }
        }
    }

    func namesAndCategories() -> [(String, String)] {
        return tableBody.map { ($1.name, $1.category) }.sort {
            let result = $0.1.localizedCaseInsensitiveCompare($1.1) // Category

            if result != .OrderedSame {
                return true
            }

            return $0.0.localizedCaseInsensitiveCompare($1.0) == .OrderedAscending // Name
        }
    }

    func gradeSystems() -> [GradeSystem] {
        return namesAndCategories().reduce([GradeSystem](), combine: { (var result:[GradeSystem], pair:(name:String, category:String)) -> [GradeSystem] in
            if let gradeSystem = self.gradeSystemForName(pair.name, category: pair.category) {
                result.append(gradeSystem)
            }

            return result
        })
    }

    func gradeSystemForName(name:String, category:String) -> GradeSystem? {
        let key = "\(name)-\(category)"
        return tableBody[key]
    }

    func gradeSystemsForLocale(locale:String) -> [GradeSystem] {
        return tableBody.reduce([GradeSystem]()) { (tmp: [GradeSystem], dict:(name: String, gradeSystem: GradeSystem)) -> [GradeSystem] in
            var result = tmp

            if dict.gradeSystem.locales.contains(locale) {
                result.append(dict.gradeSystem)
            }

            return result
        }.sort({ (a:GradeSystem, b:GradeSystem) -> Bool in
            return a.name.caseInsensitiveCompare(b.name) == .OrderedAscending
        })
    }
}