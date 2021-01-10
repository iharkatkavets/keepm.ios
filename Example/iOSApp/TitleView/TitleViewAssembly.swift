//
//  TitleViewAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation


class TitleViewAssembly: Assembly {
    func assemble(container: Container) {
        container.register(TitleViewInput.self) { (resolver, completion: @escaping (String) -> Void) in
            let router = TitleViewRouter(withResolver: container)
            let viewModel = TitleViewModel(withResolver: container, completion: completion)
            let controller = TitleViewController(withViewModel: viewModel,
                                                 resolver: container)
            router.viewController = controller
            viewModel.router = router
            return controller
        }
    }
}
