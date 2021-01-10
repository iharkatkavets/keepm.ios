//
//  TitleViewRouter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Swinject

class TitleViewRouter {
    let resolver: Resolver
    weak var viewController: TitleViewController!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }

    func close(completion: (() -> Void)? = nil) {
        viewController.dismiss(animated: true, completion: completion)
    }
}
