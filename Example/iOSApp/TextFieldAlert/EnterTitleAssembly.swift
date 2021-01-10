//
//  EnterTitleAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/23/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation

class EnterTitleAssembly: Assembly {
    func assemble(container: Container) {
        container.register(EnterTitleCoordinatorInput.self) { resolver in
            let coordinator = EnterTitleCoordinator()
            return coordinator
        }
    }
}
