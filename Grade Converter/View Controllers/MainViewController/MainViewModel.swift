//
//  MainViewModel.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/12/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class MainViewModel {

    struct MainModelSection: AnimatableSectionModelType, Equatable {
        var items: [MainModel]
        var header: String

        var identity: String {
            return header
        }

        init(items: [MainModel]) {
            self.items = items
            header = ""
        }

        init(original: MainModelSection, items: [MainModel]) {
            self = original
            self.items = items
        }

        static func ==(lhs: MainModelSection, rhs: MainModelSection) -> Bool {
            return lhs.header == rhs.header
        }
    }

    // Can't see how I can make this a protocol. It looks like if we have different type of models as Item in
    // AnimatableSectionModelType, there is no way to make them as structs.
    // We need to call them as class and subclass for different type of models.
    class MainModel: IdentifiableType, Equatable {
        public static func == (lhs: MainModel, rhs: MainModel) -> Bool {
            return lhs.equalTo(rhs)
        }

        var identity: String {
            assertionFailure("We shouldn't call MainModel directly. Only subclass should be used.")
            return ""
        }

        func equalTo(_: MainModel) -> Bool {
            assertionFailure("We shouldn't call MainModel directly. Only subclass should be used.")
            return false
        }
    }

    class GradeModel: MainModel {

        private override init() {
            gradeSystem = nil
            currentIndexes = []
            super.init()
        }

        convenience init(gradeSystem: GradeSystem, currentIndexes: [Int]) {
            self.init()
            self.gradeSystem = gradeSystem
            self.currentIndexes = currentIndexes
        }

        override func equalTo(_ rhs: MainModel) -> Bool {
            guard let other = rhs as? GradeModel else {
                return false
            }

            if gradeSystem != other.gradeSystem {
                return false
            }

            if currentIndexes != other.currentIndexes {
                return false
            }

            return true
        }

        override var identity: String {
            return gradeSystem?.key ?? ""
        }

        var gradeSystem: GradeSystem?
        var currentIndexes: [Int]
    }

    class StringModel: MainModel {
        var string: String

        private override init() {
            string = ""
            super.init()
        }

        convenience init(string: String) {
            self.init()
            self.string = string
        }

        override func equalTo(_ rhs: MainModel) -> Bool {
            guard let other = rhs as? StringModel else {
                return false
            }
            return string == other.string
        }

        override var identity: String {
            return string
        }
    }

    private var selectedGradeSystemsVar: Variable<[GradeSystem]>
    private var currentIndexesVar: Variable<[Int]>
    private var baseSystemVar: Variable<GradeSystem?>

    private var observers = [NSObjectProtocol]()

    var mainModels: Observable<[MainModelSection]>

    var selectedGradeSystemCount: Int {
        return selectedGradeSystemsVar.value.count
    }

    init() {
        selectedGradeSystemsVar = Variable<[GradeSystem]>(SystemLocalStorage().selectedGradeSystems())
        currentIndexesVar = Variable<[Int]>(SystemLocalStorage().currentIndexes())
        baseSystemVar = Variable<GradeSystem?>(SystemLocalStorage().baseSystem())

        mainModels = Observable.combineLatest(selectedGradeSystemsVar.asObservable(), currentIndexesVar.asObservable(), baseSystemVar.asObservable())
            .map({ (arg) -> [MainModelSection] in

                let (selectedGradeSystems, currentIndexes, _) = arg
                let models = selectedGradeSystems.map({ (gradeSystem) -> GradeModel in
                    GradeModel(gradeSystem: gradeSystem, currentIndexes: currentIndexes)
                }) + [StringModel(string: "More...")]

                return [MainModelSection(items: models)]
            })

        registerForNotifications()
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    fileprivate func registerForNotifications() {
        observers.append(NotificationCenter.default.addObserver(forName: NotificationTypes.systemSelectionChangedNotification.notificationName(), object: nil, queue: nil) { [weak self] _ in
            self?.selectedGradeSystemsVar.value = SystemLocalStorage().selectedGradeSystems()
        })

        observers.append(NotificationCenter.default.addObserver(forName: NotificationTypes.currentIndexChangedNotification.notificationName(), object: nil, queue: nil) { [weak self] _ in
            self?.currentIndexesVar.value = SystemLocalStorage().currentIndexes()
        })

        observers.append(NotificationCenter.default.addObserver(forName: NotificationTypes.baseSystemChangedNotification.notificationName(), object: nil, queue: nil) { [weak self] _ in
            self?.baseSystemVar.value = SystemLocalStorage().baseSystem()
        })
    }

    func deleteGradeSystem(at index: Int, commit: Bool = true) {
        var gradeSystems = selectedGradeSystemsVar.value

        guard gradeSystems.count > index else {
            return
        }

        gradeSystems.remove(at: index)
        setSelectedGradeSystems(gradeSystems, commit: commit)
    }

    func reorderGradeSystem(from fromIndex: Int, to toIndex: Int, commit: Bool = true) {
        var gradeSystems = selectedGradeSystemsVar.value

        guard gradeSystems.count > fromIndex else {
            return
        }

        guard gradeSystems.count > toIndex else {
            return
        }

        let origSystem = gradeSystems[fromIndex]
        gradeSystems[fromIndex] = gradeSystems[toIndex]
        gradeSystems[toIndex] = origSystem

        setSelectedGradeSystems(gradeSystems, commit: commit)
    }

    func setSelectedGradeSystems(_ gradeSystems: [GradeSystem], commit: Bool = true) {
        if commit {
            SystemLocalStorage().setSelectedGradeSystems(gradeSystems)
        } else {
            selectedGradeSystemsVar.value = gradeSystems
        }
    }

    func commitGradeSystemSelectionChange() {
        SystemLocalStorage().setSelectedGradeSystems(selectedGradeSystemsVar.value)
    }

    func setCurrentIndexes(_ currentIndexes: [Int]) {
        SystemLocalStorage().setCurrentIndexes(currentIndexes)
    }

    func updateBaseSystem(to baseSystem: GradeSystem) {
        SystemLocalStorage().setBaseSystem(baseSystem)
    }
}
