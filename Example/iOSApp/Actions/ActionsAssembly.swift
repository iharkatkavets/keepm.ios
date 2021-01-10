//
//  ActionsAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation


class ActionsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ActionsViewInput.self) { (resolver, actions: [TreeAction], completion: @escaping (TreeAction) -> Void) in
            let router = ActionsRouter(withResolver: container)
            let viewModel = ActionsViewModel(withResolver: container)
            let controller = ActionsViewController(withViewModel: viewModel,
                                                   resolver: container, actions: actions, completion: completion)
            router.view = controller
            viewModel.router = router
            return controller
        }
    }
}
