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

    enum MainModel: IdentifiableType, Equatable {
        case gradeModel(gradeSystem: GradeSystem, currentIndexes: [Int])
        case stringModel(string: String)

        public static func == (lhs: MainModel, rhs: MainModel) -> Bool {
            switch lhs {
            case let .gradeModel(lhsGradeSystem, lhsCurrentIndexes):
                switch rhs {
                case let .gradeModel(rhsGradeSystem, rhsCurrentIndexes):
                    // This is a hack to avoid rerendering of the base system
                    if SystemLocalStorage().isBaseSystem(rhsGradeSystem) {
                        return true
                    }
                    if lhsGradeSystem != rhsGradeSystem {
                        return false
                    }
                    if lhsCurrentIndexes != rhsCurrentIndexes {
                        return false
                    }
                    return true
                case .stringModel:
                    return false
                }
            case let .stringModel(lhsString):
                switch rhs {
                case .gradeModel:
                    return false
                case let .stringModel(rhsString):
                    return lhsString == rhsString
                }
            }
        }

        var identity: String {
            switch self {
            case let .gradeModel(gradeSystem, _):
                return gradeSystem.key
            case let .stringModel(string):
                return string
            }
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
                let models = selectedGradeSystems.map({ (gradeSystem) -> MainModel in
                    MainModel.gradeModel(gradeSystem: gradeSystem, currentIndexes: currentIndexes)
                }) + [MainModel.stringModel(string: "More...")]

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
