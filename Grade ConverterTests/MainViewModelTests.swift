//
//  MainViewModelTests.swift
//  Grade ConverterTests
//
//  Created by Yuichi Fujiki on 1/17/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import XCTest
import RxSwift
@testable import Grade_Converter

class MainViewModelTests: XCTestCase {

    var userDefaults: UserDefaults!
    var mainViewModel: MainViewModel!
    var compositeDisposable: CompositeDisposable!

    override func setUp() {
        compositeDisposable = CompositeDisposable()

        userDefaults = UserDefaults(suiteName: "UnitTest")
        LocalStorageImpl(userDefaults: userDefaults).injectToApp()

        mainViewModel = MainViewModel()
    }

    override func tearDown() {
        if !compositeDisposable.isDisposed {
            compositeDisposable.dispose()
        }

        userDefaults.removePersistentDomain(forName: "UnitTest")
    }

    func testDeleteGradeSystemNoCommit() {
        // 1. Event comes in
        let disposable = mainViewModel.mainModels
            .skip(1)
            .subscribe { sections in
                let initialCount = kNSUserDefaultsDefaultGradeSystem.count + 1 // section models include "Add" row model
                let items = sections.element!.first!.items
                XCTAssertEqual(initialCount - 1, items.count)
            }
        _ = compositeDisposable.insert(disposable)

        mainViewModel.deleteGradeSystem(at: 0, commit: false)

        // 2. The state of LocalStorage does NOT change
        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem, SystemLocalStorage().selectedGradeSystems())
    }

    func testDeleteGradeSystemWithCommit() {
        // 1. Event comes in
        let disposable = mainViewModel.mainModels
            .skip(1)
            .subscribe { sections in
            let initialCount = kNSUserDefaultsDefaultGradeSystem.count + 1 // section models include "Add" row model
            let items = sections.element!.first!.items
            XCTAssertEqual(initialCount - 1, items.count)
        }
        _ = compositeDisposable.insert(disposable)

        mainViewModel.deleteGradeSystem(at: 0, commit: true)

        // 2. The state of LocalStorage changes
        XCTAssertNotEqual(kNSUserDefaultsDefaultGradeSystem, SystemLocalStorage().selectedGradeSystems())
        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem.count - 1, SystemLocalStorage().selectedGradeSystems().count)
    }

    func testReorderGradeSystemNoCommit() {
        // 1. Event comes in
        let disposable = mainViewModel.mainModels
            .skip(1)
            .subscribe { sections in
                let initialCount = kNSUserDefaultsDefaultGradeSystem.count + 1 // section models include "Add" row model
                let items = sections.element!.first!.items
                XCTAssertEqual(initialCount, items.count)

                items.enumerated().forEach({ (index: Int, mainModel: MainViewModel.MainModel) in
                    guard case MainViewModel.MainModel.gradeModel(let gradeSystem, _) = mainModel else {
                        return
                    }

                    var correspondingIndex = index
                    if (index == 0) {
                        correspondingIndex = 2
                    } else if (index == 2) {
                        correspondingIndex = 0
                    }
                    XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem[correspondingIndex], gradeSystem)
                })

        }
        _ = compositeDisposable.insert(disposable)

        mainViewModel.reorderGradeSystem(from: 0, to: 2, commit: false)

        // Storage has NOT changed status yet
        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem.count, SystemLocalStorage().selectedGradeSystems().count)
        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem, SystemLocalStorage().selectedGradeSystems())
    }

    func testReorderGradeSystemWithCommit() {
        // 1. Event comes in
        let disposable = mainViewModel.mainModels
            .skip(1)
            .subscribe { sections in
                let initialCount = kNSUserDefaultsDefaultGradeSystem.count + 1 // section models include "Add" row model
                let items = sections.element!.first!.items
                XCTAssertEqual(initialCount, items.count)

                items.enumerated().forEach({ (index: Int, mainModel: MainViewModel.MainModel) in
                    guard case MainViewModel.MainModel.gradeModel(let gradeSystem, _) = mainModel else {
                        return
                    }

                    var correspondingIndex = index
                    if (index == 0) {
                        correspondingIndex = 2
                    } else if (index == 2) {
                        correspondingIndex = 0
                    }
                    XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem[correspondingIndex].key, gradeSystem.key)
                })

        }
        _ = compositeDisposable.insert(disposable)

        mainViewModel.reorderGradeSystem(from: 0, to: 2)

        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem.count, SystemLocalStorage().selectedGradeSystems().count)

        // Storage has changed status
        SystemLocalStorage().selectedGradeSystems().enumerated().forEach { (index, gradeSystem) in
            var correspondingIndex = index
            if (index == 0) {
                correspondingIndex = 2
            } else if (index == 2) {
                correspondingIndex = 0
            }
            XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem[correspondingIndex], gradeSystem)
        }
    }

    func testSetGradeSystemsNoCommit() {
        let gradeSystems = [
            GradeSystemTable.sharedInstance.gradeSystemForName("Ogawayama", category: "Boulder")!,
            GradeSystemTable.sharedInstance.gradeSystemForName("Yosemite Decimal System", category: "Sports")!
        ]

        let disposable = mainViewModel.mainModels
            .skip(1)
            .subscribe { sections in
                let initialCount = gradeSystems.count + 1 // section models include "Add" row model
                let items = sections.element!.first!.items
                XCTAssertEqual(initialCount, items.count)
        }

        _ = compositeDisposable.insert(disposable)

        mainViewModel.setSelectedGradeSystems(gradeSystems, commit: false)

        // No commit to the storage
        XCTAssertNotEqual(gradeSystems, SystemLocalStorage().selectedGradeSystems())
        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem, SystemLocalStorage().selectedGradeSystems())
    }

    func testSetGradeSystemsWithCommit() {
        let gradeSystems = [
            GradeSystemTable.sharedInstance.gradeSystemForName("Ogawayama", category: "Boulder")!,
            GradeSystemTable.sharedInstance.gradeSystemForName("Yosemite Decimal System", category: "Sports")!
        ]

        let disposable = mainViewModel.mainModels
            .skip(1)
            .subscribe { sections in
                let initialCount = gradeSystems.count + 1 // section models include "Add" row model
                let items = sections.element!.first!.items
                XCTAssertEqual(initialCount, items.count)
        }

        _ = compositeDisposable.insert(disposable)

        mainViewModel.setSelectedGradeSystems(gradeSystems)

        // No commit to the storage
        XCTAssertEqual(gradeSystems, SystemLocalStorage().selectedGradeSystems())
    }


}
