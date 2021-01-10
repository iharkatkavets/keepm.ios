//
//  DownloadingViewAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation


class DownloadingViewAssembly: Assembly {
    func assemble(container: Container) {
        container.register(DownloadingViewInput.self) { resolver in
            let router = DownloadingViewRouter(withResolver: container)
            let viewModel = DownloadingViewModel(withResolver: container)
            let controller = DownloadingViewController(withViewModel: viewModel,
                                                                      resolver: container)
            router.viewController = controller
            viewModel.router = router
            return controller
        }
    }
}
