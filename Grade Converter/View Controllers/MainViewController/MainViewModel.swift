//
//  MainViewModel.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/12/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation
import RxSwift

protocol MainModel {
}

class MainViewModel {

    public struct GradeModel: MainModel, Equatable {
        public static func == (lhs: GradeModel, rhs: GradeModel) -> Bool {
            return lhs.gradeSystem.key == rhs.gradeSystem.key
        }

        var gradeSystem: GradeSystem
        var currentIndexes: [Int]
    }

    public struct StringModel: MainModel {
        var string: String
    }

    private var selectedGradeSystemsVar: Variable<[GradeSystem]>
    private var currentIndexesVar: Variable<[Int]>
    private var baseSystemVar: Variable<GradeSystem?>

    private var observers = [NSObjectProtocol]()

    var mainModels: Observable<[MainModel]>

    var selectedGradeSystemCount: Int {
        return selectedGradeSystemsVar.value.count
    }

    init() {
        selectedGradeSystemsVar = Variable<[GradeSystem]>(SystemLocalStorage().selectedGradeSystems())
        currentIndexesVar = Variable<[Int]>(SystemLocalStorage().currentIndexes())
        baseSystemVar = Variable<GradeSystem?>(SystemLocalStorage().baseSystem())

        mainModels = Observable.combineLatest(selectedGradeSystemsVar.asObservable(), currentIndexesVar.asObservable(), baseSystemVar.asObservable())
            .map({ (arg) -> [MainModel] in

                let (selectedGradeSystems, currentIndexes, _) = arg
                return selectedGradeSystems.map({ (gradeSystem) -> MainModel in
                    GradeModel(gradeSystem: gradeSystem, currentIndexes: currentIndexes)
                }) + [StringModel(string: "More...")]
            })
        //        selectedGradeSystems = selectedGradeSystemsVar.asObservable()
        //        baseSystem = baseSystemVar.asObservable().takeLast(2)
        //        currentIndexes = Observable.combineLatest(currentIndexesVar.asObservable(), baseSystem)

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

        //        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kEmailComposingNotification), object: nil, queue: nil, using: { [weak self] (_: Notification) in
        //            if MFMailComposeViewController.canSendMail() {
        //                let composeViewController = MFMailComposeViewController()
        //                composeViewController.mailComposeDelegate = self
        //                composeViewController.setToRecipients([kSupportEmailAddress])
        //                composeViewController.setSubject(kSupportEmailSubject)
        //                composeViewController.navigationBar.tintColor = UIColor.white
        //
        //                self?.dismiss(animated: false, completion: { [weak self] () in
        //                    self?.present(composeViewController, animated: true, completion: nil)
        //                })
        //            }
        //        }))
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
