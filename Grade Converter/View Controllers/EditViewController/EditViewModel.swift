//
//  EditViewModel.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/16/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class EditViewModel {

    struct EditModelSection: AnimatableSectionModelType, Equatable {
        var items: [EditModel]
        var header: String

        var identity: String {
            return header
        }

        init(items: [EditModel]) {
            self.items = items
            header = ""
        }

        init(original: EditModelSection, items: [EditModel]) {
            self = original
            self.items = items
        }

        static func ==(lhs: EditModelSection, rhs: EditModelSection) -> Bool {
            return lhs.header == rhs.header
        }
    }

    struct EditModel: IdentifiableType, Equatable {
        var gradeSystem: GradeSystem

        public static func == (lhs: EditModel, rhs: EditModel) -> Bool {
            return lhs.gradeSystem == rhs.gradeSystem
        }

        var identity: String {
            return gradeSystem.key
        }
    }

    private var observers = [NSObjectProtocol]()
    private var gradeSystemsVar: Variable<[GradeSystem]>

    var editModels: Observable<[EditModelSection]>

    init() {
        gradeSystemsVar = Variable<[GradeSystem]>(SystemLocalStorage().unselectedGradeSystems())

        editModels = gradeSystemsVar.asObservable().map({ (gradeSystems) -> [EditModelSection] in
            let editModels = gradeSystems.map({ (gradeSystem) -> EditModel in
                EditModel(gradeSystem: gradeSystem)
            })
            return [EditModelSection(items: editModels)]
        })

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

    func addGradeSystem(gradeSystem: GradeSystem) {
        SystemLocalStorage().addSelectedGradeSystem(gradeSystem)
    }
}
