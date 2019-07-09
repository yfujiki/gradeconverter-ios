//
//  GradeSystemTable.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire

struct GradeSystem {
    var name: String
    var category: String
    var countryCodes: [String]
    var grades: [String] = [String]()

    init(name: String, category: String, locales: [String], grades: [String]) {
        self.name = name
        self.category = category
        countryCodes = locales
        self.grades = grades
    }

    var key: String {
        return "\(name)-\(category)"
    }

    mutating func addGrade(_ grade: String) {
        grades.append(grade)
    }

    func gradeAtIndex(_ index: Int, higher: Bool) -> String {
        var convertedIndex = index
        if convertedIndex < 0 {
            convertedIndex = 0
        }
        if convertedIndex >= grades.count {
            convertedIndex = grades.count - 1
        }

        var grade = grades[convertedIndex]

        if grade.utf8.count == 0 {
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
    func areAdjacentGrades(lowGrade: String, highGrade: String) -> Bool {
        let lowIndexes = indexesForGrade(lowGrade)
        let nextToLowGrade = higherGradeFromIndexes(lowIndexes)

        return nextToLowGrade == highGrade
    }

    func localizedGradeAtIndexes(_ indexes: [Int]) -> String {
        let sortedIndexes = indexes.sorted(by: <=)

        let lowGrade = gradeAtIndex(sortedIndexes[0], higher: false)
        let highGrade = gradeAtIndex(sortedIndexes[indexes.count - 1], higher: true)

        if lowGrade == highGrade {
            return NSLocalizedString(lowGrade, comment: "Grade itself")
        } else if lowGrade.utf8.count == 0 {
            let localizedGrade = NSLocalizedString(highGrade, comment: "Grade itself")
            return "~ \(localizedGrade))"
        } else if highGrade.utf8.count == 0 {
            let localizedGrade = NSLocalizedString(lowGrade, comment: "Grade itself")
            return "\(localizedGrade) ~"
        } else if areAdjacentGrades(lowGrade: lowGrade, highGrade: highGrade) {
            let localizedLowGrade = NSLocalizedString(lowGrade, comment: "Grade itself")
            let localizedHighGrade = NSLocalizedString(highGrade, comment: "Grade itself")
            return "\(localizedLowGrade)/\(localizedHighGrade)"
        } else {
            let localizedLowGrade = NSLocalizedString(lowGrade, comment: "Grade itself")
            let localizedHighGrade = NSLocalizedString(highGrade, comment: "Grade itself")
            return "\(localizedLowGrade) ~ \(localizedHighGrade)"
        }
    }

    func indexesForGrade(_ grade: String) -> [Int] {
        var indexes = [Int]()
        for i in 0 ..< grades.count {
            if grades[i] == grade {
                indexes.append(i)
            }
        }

        return indexes
    }

    fileprivate func higherGradeAtIndex(_ index: Int) -> String? {
        for i in index ..< grades.count {
            if grades[i].utf8.count > 0 {
                return grades[i]
            }
        }
        return nil
    }

    fileprivate func lowerGradeAtIndex(_ index: Int) -> String? {
        for i in (0 ... index).reversed() {
            if grades[i].utf8.count > 0 {
                return grades[i]
            }
        }
        return nil
    }

    func higherGradeFromIndexes(_ indexes: [Int]) -> String? {
        return nextGradeFromIndexes(indexes, higher: true)
    }

    func lowerGradeFromIndexes(_ indexes: [Int]) -> String? {
        return nextGradeFromIndexes(indexes, higher: false)
    }

    fileprivate func nextGradeFromIndexes(_ indexes: [Int], higher: Bool) -> String? {
        let sortedIndexes = indexes.sorted { $0 <= $1 }

        let lowGrade = gradeAtIndex(sortedIndexes[0], higher: false)
        let highGrade = gradeAtIndex(sortedIndexes[indexes.count - 1], higher: true)

        var nextGrade: String?

        if lowGrade == highGrade {
            if higher {
                for i in sortedIndexes[indexes.count - 1] ..< grades.count {
                    if grades[i].utf8.count > 0 && grades[i] != highGrade {
                        nextGrade = grades[i]
                        break
                    }
                }
            } else {
                for i in (0 ... sortedIndexes[0]).reversed() {
                    if grades[i].utf8.count > 0 && grades[i] != lowGrade {
                        nextGrade = grades[i]
                        break
                    }
                }
            }
        } else {
            if higher && highGrade.utf8.count > 0 {
                nextGrade = highGrade
            } else if !higher && lowGrade.utf8.count > 0 {
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

extension GradeSystem: Equatable {
    static func == (this: GradeSystem, that: GradeSystem) -> Bool {
        return this.key == that.key
    }
}

class GradeSystemTable {

    static let sharedInstance = GradeSystemTable()

    private var _updated: Variable<Bool> = Variable(true)
    var updated: Observable<Bool> {
        return _updated.asObservable()
            .skip(1)
            .distinctUntilChanged()
            .filter { $0 }
    }

    fileprivate static var kBundleFilePath: String {
        return Bundle.main.path(forResource: "GradeSystemTable", ofType: "csv")!
    }

    fileprivate static var kFilePath: String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return documentDir.appending("/GradeSystemTable.csv")
    }

    // Dictionary where key => grade system name, value => array of grade number
    fileprivate var tableBody: [String: GradeSystem] = [:]

    fileprivate init() {
        moveFromBundleToDocument()
        readContentsFromFile()
    }

    fileprivate func moveFromBundleToDocument() {
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: GradeSystemTable.kFilePath) {
            do {
                try fileManager.removeItem(atPath: GradeSystemTable.kFilePath)
            } catch let error as NSError {
                fatalError("Failed to remove file \(type(of: self).kFilePath) : \(error.debugDescription)")
            }
        }

        do {
            try fileManager.copyItem(atPath: GradeSystemTable.kBundleFilePath, toPath: GradeSystemTable.kFilePath)
        } catch let error as NSError {
            fatalError("Failed to move bundle content to file \(type(of: self).kFilePath) : \(error.debugDescription)")
        }
    }

    fileprivate func readContentsFromFile() {
        do {
            let contents = try NSString(contentsOfFile: type(of: self).kFilePath, encoding: String.Encoding.utf8.rawValue)
            let lines = contents.components(separatedBy: "\r\n") as [String]

            let names = lines[0].components(separatedBy: ",") as [String]
            let categories = lines[1].components(separatedBy: ",") as [String]
            let arrayOfLocales = lines[2].components(separatedBy: ",") as [String]
            let arrayOfGrades = lines[3 ..< lines.count]

            for i in 0 ..< names.count {
                let locales = arrayOfLocales[i].components(separatedBy: " ")
                let gradeSystem = GradeSystem(name: names[i], category: categories[i], locales: locales, grades: [String]())
                tableBody[gradeSystem.key] = gradeSystem
            }

            for grades in arrayOfGrades {
                if grades.utf8.count == 0 {
                    continue
                }

                let gradesOfSameLevel = grades.components(separatedBy: ",") as [String]

                for i in 0 ..< names.count {
                    let key = "\(names[i])-\(categories[i])"
                    tableBody[key]?.addGrade(gradesOfSameLevel[i])
                }
            }

        } catch let error as NSError {
            NSLog("Failed to read contents from file \(type(of: self).kFilePath) : \(error.debugDescription)")
            abort()
        }
    }

    func namesAndCategories() -> [(String, String)] {
        return tableBody.map { ($1.name, $1.category) }.sorted {
            let result = $0.1.localizedCaseInsensitiveCompare($1.1) // Category

            if result != .orderedSame {
                return true
            }

            return $0.0.localizedCaseInsensitiveCompare($1.0) == .orderedAscending // Name
        }
    }

    func gradeSystems() -> [GradeSystem] {
        return namesAndCategories().reduce([GradeSystem]()) { (tmp: [GradeSystem], pair: (name: String, category: String)) -> [GradeSystem] in

            var result = tmp
            if let gradeSystem = gradeSystemForName(pair.name, category: pair.category) {
                result.append(gradeSystem)
            }

            return result
        }
    }

    func gradeSystemForName(_ name: String, category: String) -> GradeSystem? {
        let key = "\(name)-\(category)"
        return tableBody[key]
    }

    func gradeSystemsForCountryCode(_ countryCode: String) -> [GradeSystem] {
        return tableBody.reduce([GradeSystem]()) { (tmp: [GradeSystem], dict: (name: String, gradeSystem: GradeSystem)) -> [GradeSystem] in
            var result = tmp

            if dict.gradeSystem.countryCodes.contains(countryCode) {
                result.append(dict.gradeSystem)
            }

            return result
        }.sorted(by: { (a: GradeSystem, b: GradeSystem) -> Bool in
            a.name.caseInsensitiveCompare(b.name) == .orderedAscending
        })
    }
}
