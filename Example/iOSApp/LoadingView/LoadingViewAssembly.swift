//
//  LoadingViewAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 4/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation

class LoadingViewAssembly: Assembly {
    func assemble(container: Container) {
        container.register(LoadingViewController.self) { resolver in
            let controller = LoadingViewController(nibName: "LoadingViewController", bundle: nil)
            return controller
        }
    }
}
