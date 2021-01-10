//
//  KdbTreeRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 12/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore
import Swinject

class GroupListRouter: NSObject, UIPopoverPresentationControllerDelegate {
    let resolver: Resolver
    weak var viewController: GroupListViewController!

    init(withResolver resolver: Resolver) {
        self.resolver = resolver
    }

    func openGroup(_ node: Kdb.Group, title: String, refreshCallback: @escaping () -> Void) {
        if let kdbTreeView = resolver.resolve(GroupListViewInput.self, arguments: node, refreshCallback) {
            let nextViewController = kdbTreeView.getViewController()
            nextViewController.title = title
            viewController?.navigationController?
                .pushViewController(nextViewController, animated: true)
        }
    }

    func openEntry(_ node: Kdb.Entry, title: String, refreshCallback: @escaping () -> Void) {
        if let kdbTreeView = resolver.resolve(EntryViewInput.self, arguments: node, refreshCallback) {
            let nextViewController = kdbTreeView.getViewController()
            nextViewController.title = title
            viewController?.navigationController?
                .pushViewController(nextViewController, animated: true)
        }
    }

    func openAddEntryToGroup(_ node: Kdb.Group, refreshCallback: @escaping () -> Void) {
        if let kdbTreeView = resolver.resolve(EntryViewInput.self, arguments: node, refreshCallback) {
            let nextViewController = kdbTreeView.getViewController()
            nextViewController.title = "New Entry"
            viewController?.navigationController?
                .pushViewController(nextViewController, animated: true)
        }
    }

    func close(completion: @escaping () -> Void) {
        viewController?.dismiss(animated: true, completion: completion)
    }

    func showAddActions(_ actions: [TreeAction], completion: @escaping (TreeAction) -> Void) {
        if let settingsScreen = resolver.resolve(ActionsViewInput.self, arguments: actions, completion) {
            let controller = settingsScreen.getViewController()
            controller.modalPresentationStyle = .popover;
            controller.popoverPresentationController?.delegate = self
            controller.popoverPresentationController?.popoverBackgroundViewClass = SettingsPopoverBackgroundView.self
            controller.popoverPresentationController?.barButtonItem = viewController.addButton
            controller.preferredContentSize = CGSize(width: 200, height: CGFloat(actions.count)*treeActionButtonHeight)
            self.viewController?.getViewController().present(controller, animated: true, completion: nil)
        }
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

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
