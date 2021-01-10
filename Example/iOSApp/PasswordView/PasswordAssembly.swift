//
//  PasswordAssembly.swift
//  iOSApp
//
//  Created by igork on 2/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation
import KeePassCore

class PasswordAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PasswordViewInput.self) { (resolver, document: StorageItem, touchIDEnabled: Bool, completion: @escaping (Kdb.Tree) -> Void) in
            let router = PasswordRouter(withResolver: container)
            let servicesPool = resolver.resolve(ServicesPoolInput.self)!
            let viewModel = PasswordViewModel(withResolver: container,
                                              servicesPool: servicesPool,
                                              document: document,
                                              touchIDEnabled: touchIDEnabled,
                                              completion: completion)
            let controller = PasswordViewController(withViewModel: viewModel,
                                                    resolver: container)
            router.view = controller
            viewModel.router = router
            return controller
        }
    }
}
