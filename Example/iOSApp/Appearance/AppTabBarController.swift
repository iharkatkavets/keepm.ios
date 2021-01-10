//
//  AppTabBarController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class AppTabBarController: UITabBarController {
    let once = DispatchOnce()
    var performOnce: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        once.perform { [weak self] in
            self?.performOnce?()
        }
    }
}
