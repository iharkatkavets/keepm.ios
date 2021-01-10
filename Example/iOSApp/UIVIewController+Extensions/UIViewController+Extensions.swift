//
//  UIViewController+Extensions.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/9/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift

enum DeleteAction {
    case delete
    case cancel
}

extension UIViewController {
    func presentDeleteFileAlertController(filename: String) -> Observable<DeleteAction> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            let alertController = UIAlertController(title: "Do you want to remove '\(filename)' ?", message: nil, preferredStyle: .alert)
            let confirmDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
                observer.onNext(.delete)
                observer.onCompleted()
            }
            alertController.addAction(confirmDelete)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                observer.onNext(.cancel)
                observer.onCompleted()
            }
            alertController.addAction(cancel)
            self.present(alertController, animated: true) {

            }

            return Disposables.create()
        }
    }

    func presentInfoAlertController(string: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            let alertController = UIAlertController(title: "Info", message: string, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel) { _ in
                observer.onNext(())
                observer.onCompleted()
            }
            alertController.addAction(cancel)
            self.present(alertController, animated: true) {

            }

            return Disposables.create()
        }
    }
}


