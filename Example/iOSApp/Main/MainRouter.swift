//
//  MainViewRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 3/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Swinject

protocol MainRouterInput {
    func openFilesList()
    func openEnterPassword()
}

class MainRouter: MainRouterInput {
    let resolver: Resolver
    weak var view: MainViewInput!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }

    func openFilesList() {
        if let listViewController = resolver.resolve(FilesListViewInput.self)?.getViewController(),
            let parentViewControler = view?.getViewController() {
            parentViewControler.present(listViewController, animated: true, completion: nil)
        }
    }

    func openEnterPassword() {

    }
}
