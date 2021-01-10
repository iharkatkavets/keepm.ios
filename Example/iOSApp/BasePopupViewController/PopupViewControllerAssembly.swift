//
//  PopupViewControllerAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation

class PopupViewControllerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PopupViewInput.self) { resolver in
            let controller = PopupViewController()
            return controller
        }
    }
}
