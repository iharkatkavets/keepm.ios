//
//  ActionsRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Swinject

class ActionsRouter {
    let resolver: Resolver
    weak var view: ActionsViewController!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }
}
