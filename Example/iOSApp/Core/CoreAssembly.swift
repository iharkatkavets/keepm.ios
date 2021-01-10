//
//  CoreAssembly.swift
//  IKKeePassCore
//
//  Created by Igor Kotkovets on 7/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Swinject

class CoreAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ServicesPoolInput.self) { _ in
            return ServicesPool(resolver: container)
        }
        .inObjectScope(.weak)

        container.register(UserSettingsInterface.self) { _ in
            return UserSettings()
        }

        container.register(InitialLoaderInput.self) { _ in
            return InitialLoader(withResolver: container)
        }

        container.register(TransferringContextManagerInput.self) { _ in
            return TransferringContextManager()
        }
        .inObjectScope(.weak)

        
    }
}
