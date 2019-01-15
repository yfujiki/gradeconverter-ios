//
//  MainViewModel.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 1/12/19.
//  Copyright © 2019 Responsive Bytes. All rights reserved.
//

import Foundation
import RxSwift

class MainViewModel {
    public struct MainModel: Equatable {
        public static func == (lhs: MainModel, rhs: MainModel) -> Bool {
            return lhs.gradeSystem.key == rhs.gradeSystem.key
        }

        var gradeSystem: GradeSystem
        var currentIndexes: [Int]
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
            .map({ (selectedGradeSystems, currentIndexes, _) -> [MainModel] in
                selectedGradeSystems.map({ (gradeSystem) -> MainModel in
                    MainModel(gradeSystem: gradeSystem, currentIndexes: currentIndexes)
                })
            })
        //        selectedGradeSystems = selectedGradeSystemsVar.asObservable()
        //        baseSystem = baseSystemVar.asObservable().takeLast(2)
        //        currentIndexes = Observable.combineLatest(currentIndexesVar.asObservable(), baseSystem)

        registerForNotifications()
    }

    fileprivate func registerForNotifications() {
        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kNSUserDefaultsSystemSelectionChangedNotification), object: nil, queue: nil) { [weak self] _ in
            self?.selectedGradeSystemsVar.value = SystemLocalStorage().selectedGradeSystems()
        })

        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kGradeSelectedNotification), object: nil, queue: nil) { [weak self] (notification: Notification!) in
            if let indexes = notification.userInfo?[kNewIndexesKey] as? [Int] {
                self?.currentIndexesVar.value = indexes
                //                    if SystemLocalStorage().currentIndexes() != indexes {
                //                        SystemLocalStorage().setCurrentIndexes(indexes)
                //
                //                        if let baseCell = notification.object as? MainTableViewCell {
                //                            let baseIndexPath = strongSelf.tableView.indexPath(for: baseCell)
                //                            let baseRow = baseIndexPath == nil ? NSNotFound : baseIndexPath!.row
                //                            strongSelf.updateBaseSystemToIndex(baseRow)
                //
                //                            strongSelf.tableView.beginUpdates()
                //                            strongSelf.reloadVisibleCellsButCell(baseCell, animated: true)
                //                            strongSelf.reloadOnlyCell(baseCell, animated: false)
                //                            strongSelf.tableView.endUpdates()
                //                        }
                //                    }
            }
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
