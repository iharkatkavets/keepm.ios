//
//  UIViewController+TextAlertController.swift
//  GymMaster
//
//  Created by Igor Kotkovets on 4/7/18.
//  Copyright © 2018 Igor Kotkovets. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
    func userEnteredText(inAlertWithTitle title: String, defaultValue: String? = nil) -> Observable<String> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let alertController = self.prepareAlertControllerWith(title: title, defaultValue: defaultValue, actionTapObserver: observer)
            self.present(alertController, animated: true, completion: nil)

            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }

    func prepareAlertControllerWith(title: String, defaultValue: String?, actionTapObserver: AnyObserver<String>) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        prepareAlertControllerActions(with: actionTapObserver, defaultValue: defaultValue, for: alertController)
            .forEach { alertController.addAction($0) }
        return alertController
    }

    func prepareAlertControllerActions(with tapObserver: AnyObserver<String>, defaultValue: String?, `for` alertController: UIAlertController) -> [UIAlertAction] {
        addTextFieldWith(defaultValue: defaultValue, to: alertController)
        let accept = createAcceptAction(with: tapObserver, for: alertController)
        let cancel = createCancelAction(with: tapObserver)
        let actions = [accept, cancel]
        return actions
    }

    func addTextFieldWith(defaultValue: String?, to alertController: UIAlertController) {
        alertController.addTextField { textField in
            textField.autocapitalizationType = .sentences
            textField.text = defaultValue
            let begining = textField.beginningOfDocument
            let end = textField.endOfDocument
            let range = textField.textRange(from: begining, to: end)
            textField.selectedTextRange = range
        }
    }

    func createAcceptAction(with tapObserver: AnyObserver<String>, for alertController: UIAlertController) -> UIAlertAction {
        return UIAlertAction(title: Localizable.Alert.okAction, style: .default) { _ in
            if let titleTextField = alertController.textFields?.first,
                let text = titleTextField.text {
                tapObserver.onNext(text)
            }

            tapObserver.onCompleted()
        }
    }

    func createCancelAction(with tapObserver: AnyObserver<String>) -> UIAlertAction {
        return UIAlertAction(title: Localizable.Alert.cancelAction, style: .cancel) { _ in
            tapObserver.onCompleted()
        }
    }
}
