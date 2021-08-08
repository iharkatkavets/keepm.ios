//
//  AppSettingsViewAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/29/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation


class AppSettingsViewAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AppSettingsViewInput.self) { resolver in
            let router = AppSettingsViewRouter(withResolver: container)
            let viewModel = AppSettingsPresenter(withResolver: container)
            let controller = AppSettingsViewController(withViewModel: viewModel,
                                                                      resolver: container)
            router.viewController = controller
            viewModel.view = controller
            viewModel.router = router
            return controller
        }
    }
}
