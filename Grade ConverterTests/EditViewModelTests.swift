//
//  EditViewModelTests.swift
//  Grade ConverterTests
//
//  Created by Yuichi Fujiki on 1/17/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import XCTest
import RxSwift
@testable import Grade_Converter

class EditViewModelTests: XCTestCase {

    var userDefaults: UserDefaults!
    var editViewModel: EditViewModel!
    var compositeDisposable: CompositeDisposable!

    override func setUp() {
        compositeDisposable = CompositeDisposable()

        userDefaults = UserDefaults(suiteName: "UnitTest")
        LocalStorageImpl(userDefaults: userDefaults).injectToApp()

        editViewModel = EditViewModel()
    }

    override func tearDown() {
        if !compositeDisposable.isDisposed {
            compositeDisposable.dispose()
        }

        userDefaults.removePersistentDomain(forName: "UnitTest")
    }

    func testAddGradeSystems() {
        let exp = expectation(description: "Selecting should remove item from editModels")

        let gradeSystem = GradeSystemTable.sharedInstance.gradeSystemForName("Brazil", category: "Boulder")!

        let disposable = editViewModel.editModels
            .skip(1)
            .subscribe { sections in
                let initialCountToSelect = GradeSystemTable.sharedInstance.gradeSystems().count - kNSUserDefaultsDefaultGradeSystem.count
                let itemsToSelect = sections.element!.first!.items
                XCTAssertEqual(initialCountToSelect - 1, itemsToSelect.count)

                exp.fulfill()
        }

        _ = compositeDisposable.insert(disposable)

        editViewModel.addGradeSystem(gradeSystem: gradeSystem)

        XCTAssertEqual(kNSUserDefaultsDefaultGradeSystem + [gradeSystem],
                       SystemLocalStorage().selectedGradeSystems())

        let result = XCTWaiter.wait(for: [exp], timeout: 1)
        XCTAssertEqual(.completed, result)
    }
}
