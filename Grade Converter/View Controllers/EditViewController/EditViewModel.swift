//
//  EditViewModel.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/16/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation
import RxSwift

class EditViewModel {
    private var observers = [NSObjectProtocol]()
    private var gradeSystemsVar: Variable<[GradeSystem]>

    var gradeSystems: Observable<[GradeSystem]>

    init() {
        gradeSystemsVar = Variable<[GradeSystem]>(SystemLocalStorage().unselectedGradeSystems())
        gradeSystems = gradeSystemsVar.asObservable()

        registerForNotifications()
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func snapshotGradeSystems() -> [GradeSystem] {
        return gradeSystemsVar.value
    }

    private func registerForNotifications() {
        let notificationName = NotificationTypes.systemSelectionChangedNotification.notificationName()

        observers.append(NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: { [weak self] _ in
            self?.gradeSystemsVar.value = SystemLocalStorage().unselectedGradeSystems()
        }))
    }
}
