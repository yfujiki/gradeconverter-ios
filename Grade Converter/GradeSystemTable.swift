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
    var countryCodes: [String]
    var grades: [String] = [String]()
    var isBaseSystem: Bool = false

    init(name: String, category: String, locales: [String], grades: [String]) {
        self.name = name
        self.category = category
        self.countryCodes = locales
        self.grades = grades
    }

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
        // There is no corresponding entry at that specific index
            if higher {
                if let higherGrade = higherGradeAtIndex(index) {
                    grade = higherGrade
                }
            } else {
                if let lowerGrade = lowerGradeAtIndex(index) {
                    grade = lowerGrade
                }
            }
        }

        return grade
    }

    // Assuming lowGrade and highGrade are different grade strings and order is low => high.
    func areAdjacentGrades(lowGrade lowGrade: String, highGrade: String) -> Bool {
        let lowIndexes = indexesForGrade(lowGrade)
        let nextToLowGrade = higherGradeFromIndexes(lowIndexes)

        return nextToLowGrade == highGrade
    }

    func localizedGradeAtIndexes(indexes: [Int]) -> String {
        let sortedIndexes = indexes.sort(<=)

        let lowGrade = gradeAtIndex(sortedIndexes[0], higher: false)
        let highGrade = gradeAtIndex(sortedIndexes[indexes.count - 1], higher: true)

        if lowGrade == highGrade {
            return NSLocalizedString(lowGrade, comment:"Grade itself")
        } else if lowGrade.characters.count == 0 {
            let localizedGrade = NSLocalizedString(highGrade, comment:"Grade itself")
            return "~ \(localizedGrade))"
        } else if highGrade.characters.count == 0 {
            let localizedGrade = NSLocalizedString(lowGrade, comment:"Grade itself")
            return "\(localizedGrade) ~"
        } else if areAdjacentGrades(lowGrade: lowGrade, highGrade: highGrade) {
            let localizedLowGrade = NSLocalizedString(lowGrade, comment:"Grade itself")
            let localizedHighGrade = NSLocalizedString(highGrade, comment:"Grade itself")
            return "\(localizedLowGrade)/\(localizedHighGrade)"
        } else {
            let localizedLowGrade = NSLocalizedString(lowGrade, comment:"Grade itself")
            let localizedHighGrade = NSLocalizedString(highGrade, comment:"Grade itself")
            return "\(localizedLowGrade) ~ \(localizedHighGrade)"
        }
    }

    func indexesForGrade(grade: String) -> [Int] {
        var indexes = [Int]()
        for i in 0 ..< grades.count {
            if grades[i] == grade {
                indexes.append(i)
            }
        }

        return indexes
    }

    private func higherGradeAtIndex(index: Int) -> String? {
        for i in index ..< grades.count {
            if grades[i].characters.count > 0 {
                return grades[i]

            }
        }
        return nil
    }

    private func lowerGradeAtIndex(index: Int) -> String? {
        for i in (0...index).reverse() {
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
                for i in sortedIndexes[indexes.count - 1] ..< grades.count {
                    if grades[i].characters.count > 0 && grades[i] != highGrade {
                        nextGrade = grades[i]
                        break
                    }
                }
            } else {
                for i in (0...sortedIndexes[0]).reverse() {
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

    // MARK: - localize

    var localizedName: String {
        return NSLocalizedString(name, comment: "Grade name")
    }

    var localizedCategory: String {
        return NSLocalizedString(category, comment: "Climbing category")
    }
}

func == (this: GradeSystem, that: GradeSystem) -> Bool {
    return this.name == that.name && this.category == that.category
}

class GradeSystemTable {

    static let sharedInstance = GradeSystemTable()

    private static var kFileName: String {
        return NSBundle.mainBundle().pathForResource("GradeSystemTable", ofType: "csv")!
    }

    // Dictionary where key => grade system name, value => array of grade number
    private var tableBody: [String: GradeSystem] = [:]

    private init() {
        var error: NSError?

        do {
            let contents = try NSString(contentsOfFile: self.dynamicType.kFileName, encoding: NSUTF8StringEncoding)
            let lines = contents.componentsSeparatedByString("\n") as [String]

            let names = lines[0].componentsSeparatedByString(",") as [String]
            let categories = lines[1].componentsSeparatedByString(",") as [String]
            let arrayOfLocales = lines[2].componentsSeparatedByString(",") as [String]
            let arrayOfGrades = lines[3..<lines.count]

            for i in 0 ..< names.count {
                let locales = arrayOfLocales[i].componentsSeparatedByString(" ")
                let gradeSystem = GradeSystem(name: names[i], category: categories[i], locales: locales, grades: [String]())
                tableBody[gradeSystem.key] = gradeSystem
            }

            for grades in arrayOfGrades {
                let gradesOfSameLevel = grades.componentsSeparatedByString(",") as [String]

                for i in 0 ..< names.count {
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
        return namesAndCategories().reduce([GradeSystem]()) { (tmp:[GradeSystem], pair:(name:String, category:String)) -> [GradeSystem] in

            var result = tmp;
            if let gradeSystem = gradeSystemForName(pair.name, category: pair.category) {
                result.append(gradeSystem)
            }

            return result
        }
    }

    func gradeSystemForName(name:String, category:String) -> GradeSystem? {
        let key = "\(name)-\(category)"
        return tableBody[key]
    }

    func gradeSystemsForCountryCode(countryCode:String) -> [GradeSystem] {
        return tableBody.reduce([GradeSystem]()) { (tmp: [GradeSystem], dict:(name: String, gradeSystem: GradeSystem)) -> [GradeSystem] in
            var result = tmp

            if dict.gradeSystem.countryCodes.contains(countryCode) {
                result.append(dict.gradeSystem)
            }

            return result
        }.sort({ (a:GradeSystem, b:GradeSystem) -> Bool in
            return a.name.caseInsensitiveCompare(b.name) == .OrderedAscending
        })
    }
}