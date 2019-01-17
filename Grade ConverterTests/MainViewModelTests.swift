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

        userDefaults.removeSuite(named: "UnitTest")
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
}
