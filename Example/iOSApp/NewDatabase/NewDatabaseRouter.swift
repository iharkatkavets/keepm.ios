//
//  NewDatabaseRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Swinject

class NewDatabaseRouter {
    let resolver: Resolver
    weak var viewController: NewDatabaseViewController!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }

    func dismissScreen(_ completion: @escaping () -> Void) {
        viewController.dismiss(animated: true, completion: completion)
    }
}
