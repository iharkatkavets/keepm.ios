//
//  EntryRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 12/29/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore
import Swinject

class EntryRouter {
    let resolver: Resolver
    weak var viewController: EntryViewController!

    init(withResolver resolver: Resolver) {
        self.resolver = resolver
    }

    func openNode(_ node: Kdb.Entry, title: String) {
        if let kdbTreeView = resolver.resolve(GroupListViewInput.self, argument: node) {
            let nextViewController = kdbTreeView.getViewController()
            nextViewController.title = title
            viewController?.navigationController?
                .pushViewController(nextViewController, animated: true)
        }
    }

    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func presentScreenToEnterTitle(_ completion: @escaping (String) -> Void) {
        if let titleViewController = resolver.resolve(TitleViewInput.self, argument: completion)?.getViewController(),
            let popupView = resolver.resolve(PopupViewInput.self) {
            popupView.setContentViewController(titleViewController)
            popupView.getViewController().modalTransitionStyle = .crossDissolve
            popupView.getViewController().modalPresentationStyle = .overFullScreen
            viewController.navigationController?
                .present(popupView.getViewController(), animated: true, completion: nil)
        }
    }
}
