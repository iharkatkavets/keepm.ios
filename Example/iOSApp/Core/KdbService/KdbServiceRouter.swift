//
//  KdbServiceRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 6/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Swinject
import KeePassCore

class KdbServiceRouter {
    let resolver: Resolver
    weak var rootViewController: UIViewController!

    init(withResolver resolver: Swinject.Resolver, rootViewController: UIViewController) {
        self.resolver = resolver
        self.rootViewController = rootViewController
    }

    func showErrorWithTitle(_ title: String) {
        guard let alertCoordinator = resolver.resolve(ErrorAlertViewCoordinatorInput.self) else {
            return
        }

        return alertCoordinator.show(presentingViewController: rootViewController, title: title, message: nil)
    }

    func openDatabaseWithPassword(_ document: StorageItem, touchIDEnabled: Bool, completion: @escaping (Kdb.Tree) -> Void) {
        if let passwordView = resolver.resolve(PasswordViewInput.self, arguments: document, touchIDEnabled, completion),
            let popupView = resolver.resolve(PopupViewInput.self) {
            let presentedViewController = passwordView.getViewController()
            popupView.setContentViewController(presentedViewController)
            popupView.getViewController().modalTransitionStyle = .crossDissolve
            popupView.getViewController().modalPresentationStyle = .overFullScreen

            let parentViewController = rootViewController.navigationController ?? rootViewController
            parentViewController?
                .present(popupView.getViewController(), animated: true, completion: nil)
        }
    }

    func openKdbTree(rootGroup: Kdb.Group, refreshCompletion: @escaping () -> Void) {
        if let kdbTreeView = resolver.resolve(GroupListViewInput.self, arguments: rootGroup, refreshCompletion) {
            let kdbNavigationController = AppNavigationController(rootViewController: kdbTreeView.getViewController())
            kdbTreeView.setCloseButtonVisible(true)
            kdbNavigationController.modalPresentationStyle = .fullScreen

            let parentViewController = rootViewController.navigationController ?? rootViewController

            parentViewController?
            .present(kdbNavigationController, animated: true, completion: nil)
        }
    }
}
