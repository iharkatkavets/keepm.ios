//
//  ErrorAlertViewCoordinator.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 6/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import Swinject

protocol RxErrorAlertViewCoordinatorInput {
    func showAndWaitForDismiss(title: String, message: String?, _ presentingViewController: UIViewController) -> Observable<Void>
}

class RxErrorAlertViewCoordinator: RxErrorAlertViewCoordinatorInput {
    init() {
    }

    func showAndWaitForDismiss(title: String, message: String?, _ presentingViewController: UIViewController) -> Observable<Void> {
        return Observable.create { observer in
            let alertController = self.createAlertController(title: title, message: message, tapObserver: observer)
            presentingViewController.present(alertController, animated: true, completion: nil)

            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }

    func createAlertController(title: String, message: String?, tapObserver: AnyObserver<Void>? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var actions = [UIAlertAction]()
        let okAction = createOKAction(with: tapObserver)
        actions.append(okAction)
        actions.forEach { alertController.addAction($0) }
        return alertController
    }

    func createOKAction(with tapObserver: AnyObserver<Void>? = nil) -> UIAlertAction {
        return UIAlertAction(title: "OK", style: .cancel) { _ in
            if let tapObserver = tapObserver {
                tapObserver.onNext(())
                tapObserver.onCompleted()
            }
        }
    }
}
