//
//  PasswordRouter.swift
//  iOSApp
//
//  Created by igork on 2/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Swinject

class PasswordRouter {
    let resolver: Resolver
    weak var view: PasswordViewController!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }

    func close(completion: (() -> Void)? = nil) {
        view.dismiss(animated: true, completion: completion)
    }

    func presentError(_ title: String?, message: String?) {
        if let errorView = resolver.resolve(ErrorViewInput.self, arguments: title, message),
            let popupView = resolver.resolve(PopupViewInput.self) {
            let presentedViewController = errorView.getViewController()
            popupView.setContentViewController(presentedViewController)
            popupView.getViewController().modalTransitionStyle = .crossDissolve
            popupView.getViewController().modalPresentationStyle = .overFullScreen
            view
                .present(popupView.getViewController(), animated: true, completion: nil)
        }
    }

    func presentProcessingView() {
        if let processingView = resolver.resolve(ProcessingViewInput.self),
            let popupViewController = view.popupViewController {
            popupViewController.setContentViewController(processingView.getViewController())
        }
    }
}
