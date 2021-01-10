//
//  ErrorAlertViewAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 6/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation

class ErrorAlertViewAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ErrorAlertViewCoordinatorInput.self) { _ in 
            return ErrorAlertViewCoordinator()
        }
        
        container.register(RxErrorAlertViewCoordinatorInput.self) { _ in
            return RxErrorAlertViewCoordinator()
        }
    }
}
