//
//  FilesListRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 3/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Swinject
import KeePassCore
import RxSwift

class FilesListRouter {
    let resolver: Resolver
    weak var viewController: FilesListViewController!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }

    func openKdbTree(rootGroup: Kdb.Group, refreshCompletion: @escaping () -> Void) {
        if let kdbTreeView = resolver.resolve(GroupListViewInput.self, arguments: rootGroup, refreshCompletion) {
            let kdbNavigationController = AppNavigationController(rootViewController: kdbTreeView.getViewController())
            kdbTreeView.setCloseButtonVisible(true)
            kdbNavigationController.modalPresentationStyle = .fullScreen
            viewController.navigationController?
            .present(kdbNavigationController, animated: true, completion: nil)
        }
    }

    func presentScreenToEnterNewDatabaseParameters(_ completion: @escaping (_ filename: String, _ password: String, _ touchIDOn: Bool) -> Void) {
        if let newDatabaseView = resolver.resolve(NewDatabaseViewInput.self, argument: completion),
            let popupView = resolver.resolve(PopupViewInput.self) {
            let presentedViewController = newDatabaseView.getViewController()
            popupView.setContentViewController(presentedViewController)
            popupView.getViewController().modalTransitionStyle = .crossDissolve
            popupView.getViewController().modalPresentationStyle = .overFullScreen
            viewController.navigationController?
                .present(popupView.getViewController(), animated: true, completion: nil)
        }
    }

    func presentError(_ title: String?, message: String?) {
        if let errorView = resolver.resolve(ErrorViewInput.self, arguments: title, message),
            let popupView = resolver.resolve(PopupViewInput.self) {
            let presentedViewController = errorView.getViewController()
            popupView.setContentViewController(presentedViewController)
            popupView.getViewController().modalTransitionStyle = .crossDissolve
            popupView.getViewController().modalPresentationStyle = .overFullScreen
            viewController.navigationController?
                .present(popupView.getViewController(), animated: true, completion: nil)
        }
    }

    func openDatabaseWithPassword(_ document: StorageItem, touchIDEnabled: Bool, completion: @escaping (Kdb.Tree) -> Void) {
        if let passwordView = resolver.resolve(PasswordViewInput.self, arguments: document, touchIDEnabled, completion),
            let popupView = resolver.resolve(PopupViewInput.self) {
            let presentedViewController = passwordView.getViewController()
            popupView.setContentViewController(presentedViewController)
            popupView.getViewController().modalTransitionStyle = .crossDissolve
            popupView.getViewController().modalPresentationStyle = .overCurrentContext
            viewController.navigationController?
                .present(popupView.getViewController(), animated: true, completion: nil)
        }
    }

    func presentError(_ title: String) {
        guard let alertCoordinator = resolver.resolve(ErrorAlertViewCoordinatorInput.self) else {
            return
        }
        alertCoordinator.show(presentingViewController: viewController, title: title)
    }

    func presentDeleteFileAlert(filename: String, completion: @escaping (DeleteAction) -> Void) {
        let alertController = UIAlertController(title: "Do you want to remove '\(filename)' ?", message: nil, preferredStyle: .alert)
        let confirmDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            completion(.delete)
        }
        alertController.addAction(confirmDelete)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(.cancel)
        }
        alertController.addAction(cancel)
        self.viewController.present(alertController, animated: true) 
    }
}
