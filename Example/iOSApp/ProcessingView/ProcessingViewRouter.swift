//
//  ProcessingViewRouter.swift
//  iOSApp
//
//  Created by igork on 2/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Swinject

class ProcessingViewRouter {
    let resolver: Resolver
    weak var viewController: ProcessingViewController!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }
}
