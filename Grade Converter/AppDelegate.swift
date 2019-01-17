//
//  AppDelegate.swift
//  Grade Converter
//
//  Created by Yuichi Fujiki on 6/20/15.
//  Copyright (c) 2015 Responsive Bytes. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Firebase
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Dependency injection for the single store
    var localStorage: LocalStorage!

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Fabric.with([Crashlytics()])
        FirebaseApp.configure()

        localStorage = LocalStorageStandardImpl() as LocalStorage

        #if DEBUG
        #else
            if ProcessInfo.processInfo.environment.index(forKey: "UITEST") == nil {
                // We don't want to show this in UITEST or during debug
                SKStoreReviewController.requestReview()
            }
        #endif

        let fontName = FontNameForCurrentLang()
        let boldFontName = BoldFontNameForCurrentLang()
        let navigationBarTitleFontSize = NavigationBarTitleFontSize()
        let navigationBarItemFontSize = NavigationBarItemFontSize()

        // navigation bar bar color
        UINavigationBar.appearance().barTintColor = UIColor.myAquaColor()
        // navigation bar title text color
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: fontName, size: navigationBarTitleFontSize)!,
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ]
        // navigation items title colors
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: fontName, size: navigationBarItemFontSize)!,
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ], for: UIControl.State())

        //        window?.tintColor = UIColor.whiteColor() <= This works for navigation bar item if it is only color

        // other labels
        UILabel.appearance().substituteFontName = fontName
        UILabel.appearance().substituteBoldFontName = boldFontName

        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        Analytics.setUserProperty(CurrentLang().string, forName: "lang")
        Analytics.setUserProperty(CurrentCountry().string, forName: "country")
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [:])
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID: SystemLocalStorage().selectedGradeSystemNamesCSV()])

        _ = GradeSystemTable.sharedInstance.downloadNewFile().subscribe(
            onNext: {
            }
        )
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
