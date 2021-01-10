//
//  InitialLoader.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/9/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Swinject
import Foundation

protocol InitialLoaderInput {
    func start(window: UIWindow) -> UIViewController
}

class InitialLoader: InitialLoaderInput {
    private let resolver: Resolver
    init(withResolver resolver: Resolver) {
        self.resolver = resolver
    }
    
    func start(window: UIWindow) -> UIViewController {
        let tabBarController = AppTabBarController()
        var viewControllers = [UIViewController]()
        
        if let listViewController = resolver.resolve(FilesListViewInput.self) {
            let navController = AppNavigationController(rootViewController: listViewController.getViewController())
            navController.tabBarItem = UITabBarItem(title: "Device", image: nil, tag: 0)
            viewControllers.append(navController)
        }
        if let googleDriveController = resolver.resolve(GoogleDriveViewInput.self) {
            let navController = AppNavigationController(rootViewController: googleDriveController.getViewController())
            navController.tabBarItem = UITabBarItem(title: "Google Drive", image: nil, tag: 1)
            viewControllers.append(navController)
        }
        if let settingsViewController = resolver.resolve(AppSettingsViewInput.self) {
            let navController = AppNavigationController(rootViewController: settingsViewController.getViewController())
            navController.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 2)
            viewControllers.append(navController)
        }
        tabBarController.viewControllers = viewControllers
        
        if let servicesPool = resolver.resolve(ServicesPoolInput.self),
            let appSettings = servicesPool.appSettingsService,
            appSettings.bool(forKey: .privacyPolicyAccepted) == false,
            let privacyPolicyViewController = resolver.resolve(PrivacyPolicyViewController.self) {
            privacyPolicyViewController.modalPresentationStyle = .overFullScreen
            privacyPolicyViewController.modalTransitionStyle = .crossDissolve
            tabBarController.performOnce = {
                tabBarController.present(privacyPolicyViewController, animated: true)
            }
        }
        
        return tabBarController
    }
}
