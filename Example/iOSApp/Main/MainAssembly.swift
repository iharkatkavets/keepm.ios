//
//  MainAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Swinject

class MainAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MainViewInput.self) { (resolver: Resolver) in
            MainViewController(withModel: resolver.resolve(MainViewModelInput.self)!)
        }
        container.register(MainViewModelInput.self) { (resolver: Resolver) in
            return MainViewModel(withUser: resolver.resolve(UserSettingsInterface.self)!)
            }
            .initCompleted { resolver, model in
                let model = model as? MainViewModel
                model?.router = resolver.resolve(MainRouterInput.self)

        }
        container.register(MainRouterInput.self) { resolver in
            return MainRouter(withResolver: resolver)
            }
            .initCompleted { resolver, router in
                let router = router as? MainRouter
                router?.view = resolver.resolve(MainViewInput.self)

        }
    }
}
