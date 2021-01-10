//
//  ErrorAlertViewCoordinator.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 6/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Swinject

protocol ErrorAlertViewCoordinatorInput {
    func show(presentingViewController: UIViewController, title: String, message: String?)
    func show(presentingViewController: UIViewController, title: String)
}

class ErrorAlertViewCoordinator: ErrorAlertViewCoordinatorInput {
    func show(presentingViewController: UIViewController, title: String) {
        show(presentingViewController: presentingViewController, title: title, message: nil)
    }

    func show(presentingViewController: UIViewController, title: String, message: String? = nil) {
        let alertController = self.createAlertController(title: title, message: message)
        presentingViewController.present(alertController, animated: true, completion: nil)
    }

    func createAlertController(title: String, message: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var actions = [UIAlertAction]()
        let okAction = createOKAction()
        actions.append(okAction)
        actions.forEach { alertController.addAction($0) }
        return alertController
    }

    func createOKAction() -> UIAlertAction {
        return UIAlertAction(title: "OK", style: .cancel) { _ in

        }
    }
}
