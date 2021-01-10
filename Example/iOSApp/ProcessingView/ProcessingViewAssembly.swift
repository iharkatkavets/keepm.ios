//
//  ProcessingViewAssembly.swift
//  iOSApp
//
//  Created by igork on 2/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation


class ProcessingViewAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ProcessingViewInput.self) { resolver in
            let router = ProcessingViewRouter(withResolver: container)
            let viewModel = ProcessingViewModel(withResolver: container)
            let controller = ProcessingViewController(withViewModel: viewModel,
                                                                      resolver: container)
            router.viewController = controller
            viewModel.router = router
            return controller
        }
    }
}
