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

    //    var selectedGradeSystems: Observable<[GradeSystem]>
    //    var currentIndexes: Observable<([Int], GradeSystem?)>
    //    var baseSystem: Observable<GradeSystem?>

    var mainModel: Observable<[MainModel]>

    init() {
        selectedGradeSystemsVar = Variable<[GradeSystem]>(SystemLocalStorage().selectedGradeSystems())
        currentIndexesVar = Variable<[Int]>(SystemLocalStorage().currentIndexes())
        baseSystemVar = Variable<GradeSystem?>(SystemLocalStorage().selectedGradeSystems().first(where: { (system) -> Bool in
            system.isBaseSystem
        }))

        mainModel = Observable.combineLatest(selectedGradeSystemsVar.asObservable(), currentIndexesVar.asObservable(), baseSystemVar.asObservable())
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

    func updateBaseSystemToIndex(_ index: Int) {
        let gradeSystems = selectedGradeSystemsVar.value.enumerated().map { (i: Int, gradeSystem: GradeSystem) -> GradeSystem in
            var gradeSystemCopy = gradeSystem
            if i == index {
                gradeSystemCopy.isBaseSystem = true
                baseSystemVar.value = gradeSystem
            } else {
                gradeSystemCopy.isBaseSystem = false
            }
            return gradeSystemCopy
        }

        selectedGradeSystemsVar.value = gradeSystems
    }
}
