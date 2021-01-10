//
//  ErrorHandler.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 7/19/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import os.log

protocol ErrorHandlerInput {
    func presentError(title: String)
}

class ErrorHandler: ErrorHandlerInput {
    weak var viewController: UIViewController?
    private let outLog = OSLog(subsystem: APP_LOG_SUBSYSTEM, category: String(describing: ErrorHandler.self))

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func presentError(title: String) {

    }
}
