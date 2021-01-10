//
//  ErrorViewAssembly.swift
//  iOSApp
//
//  Created by igork on 2/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation

class ErrorViewAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ErrorViewInput.self) { (resolver, title: String?, message: String?) in
            let controller = ErrorViewController()
            controller.errorTitle = title
            controller.errorMessage = message

            return controller
        }
    }
}
