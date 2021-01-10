//
//  AppDelegate.swift
//  IKKeePassCore
//
//  Created by Igor Kotkovets on 05/29/2017.
//  Copyright (c) 2017 Igor Kotkovets. All rights reserved.
//

import UIKit
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let diResolver = {
        Assembler([CoreAssembly(), MainAssembly(),
                   PasswordAssembly(), FilesListAssembly(),
                   GroupListAssembly(), EntryAssembly(),
                   GoogleDriveAssembly(), GoogleDriveSettingsAssembly(),
                   ActionsAssembly(), EnterTitleAssembly(),
                   NewDatabaseAssembly(), PopupViewControllerAssembly(),
                   ErrorViewAssembly(), ProcessingViewAssembly(),
                   PrivacyPolicyViewAssembly(), TitleViewAssembly(),
                   AppSettingsViewAssembly(), LoadingViewAssembly(),
                   ErrorAlertViewAssembly()]).resolver
    }()
    var window: UIWindow? = {UIWindow(frame: UIScreen.main.bounds)}()
    var servicesPool: ServicesPoolInput!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppApperance().apply()

        DemoFilesCopier().createDevFilesIfNeeded()

        servicesPool = diResolver.resolve(ServicesPoolInput.self)
        servicesPool.startKeyboardService()
        servicesPool.startFirebase()

        _ = servicesPool.startAppSettingsService()
        servicesPool.startCredentialsStoreService()

        if let rootViewController = diResolver.resolve(InitialLoaderInput.self)?.start(window: window!) {
            servicesPool.startGoogleDriveService(rootViewController: rootViewController)
            self.window?.rootViewController = rootViewController
        }

        self.window?.makeKeyAndVisible()
        return true
    }
}
