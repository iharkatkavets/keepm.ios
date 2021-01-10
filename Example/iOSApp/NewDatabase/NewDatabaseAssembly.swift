//
//  NewDatabaseAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation


class NewDatabaseAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NewDatabaseViewInput.self) { (resolver, completion: @escaping (String, String, Bool) -> Void) in
            let router = NewDatabaseRouter(withResolver: container)
            let controller = NewDatabaseViewController(withResolver: container)
            let servicesPool = resolver.resolve(ServicesPoolInput.self)!
            let presenter = NewDatabasePresenter(withResolver: container, servicesPool: servicesPool, completion: completion)
            presenter.view = controller
            controller.presenter = presenter
            router.viewController = controller
            presenter.router = router
            return controller
        }
    }
}
