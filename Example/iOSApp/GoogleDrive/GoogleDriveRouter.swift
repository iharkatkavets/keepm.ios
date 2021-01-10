//
//  GoogleDriveRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/3/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore
import Swinject
import RxSwift

enum SignOutAction {
    case confirm
    case cancel
}

enum DownloadUserAction {
    case download
    case cancel
}

class GoogleDriveRouter: NSObject, UIPopoverPresentationControllerDelegate {
    let resolver: Resolver
    weak var viewController: GoogleDriveViewController!


    init(withResolver resolver: Resolver) {
        self.resolver = resolver
    }

    func openDirectory(_ directory: GoogleDriveItem) {
        if let googleDriveScreen = resolver.resolve(GoogleDriveViewInput.self, argument: directory) {
            let nextViewController = googleDriveScreen.getViewController()
            viewController?.getViewController().navigationController?
                .pushViewController(nextViewController, animated: true)
        }
    }

    func showSettings(from button: UIBarButtonItem) {
        if let settingsScreen = resolver.resolve(GoogleDriveSettingsViewInput.self) {
            let controller = settingsScreen.getViewController()
            controller.modalPresentationStyle = .popover;
            controller.popoverPresentationController?.delegate = self
            controller.popoverPresentationController?.popoverBackgroundViewClass = SettingsPopoverBackgroundView.self
            controller.popoverPresentationController?.barButtonItem = button
            controller.preferredContentSize = CGSize(width: 300, height: 99)
            self.viewController?.present(controller, animated: true, completion: nil)
        }
    }

    func presentConfirmDownloading(fileName: String, completion: @escaping (DownloadUserAction) -> Void) {
        let alertController = UIAlertController(title: "Do you want to download '\(fileName)' ?",
                                                message: "The file will be visible in 'App Files' section",
                                                preferredStyle: .alert)
        let confirmDelete = UIAlertAction(title: "Download", style: .default) { _ in
            completion(.download)
        }
        alertController.addAction(confirmDelete)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(.cancel)
        }
        alertController.addAction(cancel)
        self.viewController?.present(alertController, animated: true) {
        }
    }

    func presentLoadingIndicator(_ completion: @escaping (UIViewController) -> Void) {
        if let loadingViewController = self.resolver.resolve(LoadingViewController.self),
            let popupView = self.resolver.resolve(PopupViewInput.self) {
            popupView.setContentViewController(loadingViewController)
            popupView.getViewController().modalTransitionStyle = .crossDissolve
            popupView.getViewController().modalPresentationStyle = .overFullScreen
            self.viewController?.present(popupView.getViewController(), animated: true) {
                completion(popupView.getViewController())
            }
        }
    }

    func dismissLoadingIndicator(_ vc: UIViewController, completion: (() -> Void)? = nil) {
        vc.dismiss(animated: true, completion: completion)
    }

    func presentConfirmSignOut() -> Observable<SignOutAction> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            let alertController = UIAlertController(title: "You are about to log out from Google Drive. Are you sure?",
                                                    message: nil, preferredStyle: .alert)
            let confirmDelete = UIAlertAction(title: "Log out", style: .default) { _ in
                observer.onNext(.confirm)
                observer.onCompleted()
            }
            alertController.addAction(confirmDelete)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                observer.onNext(.cancel)
                observer.onCompleted()
            }
            alertController.addAction(cancel)
            self.viewController?.present(alertController, animated: true) {

            }

            return Disposables.create()
        }
    }


    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func presentError(_ title: String?, message: String?) {
        if let errorView = resolver.resolve(ErrorViewInput.self, arguments: title, message),
            let popupView = resolver.resolve(PopupViewInput.self) {
            let presentedViewController = errorView.getViewController()
            popupView.setContentViewController(presentedViewController)
            popupView.getViewController().modalTransitionStyle = .crossDissolve
            popupView.getViewController().modalPresentationStyle = .overFullScreen
            viewController?.present(popupView.getViewController(), animated: true, completion: nil)
        }
    }

    func presentError(_ title: String) {
        guard let alertCoordinator = resolver.resolve(ErrorAlertViewCoordinatorInput.self) else {
            return
        }
        alertCoordinator.show(presentingViewController: viewController, title: title)
    }


}
