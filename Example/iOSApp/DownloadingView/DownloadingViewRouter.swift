//
//  DownloadingViewRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Swinject

class DownloadingViewRouter {
    let resolver: Resolver
    weak var viewController: DownloadingViewController!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }
}
