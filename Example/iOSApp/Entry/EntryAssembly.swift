//
//  EntryAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 12/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Swinject
import KeePassCore

class EntryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(EntryViewInput.self) { (resolver, node: Kdb.Entry, callback: @escaping () -> Void) in
            let servicesPool = resolver.resolve(ServicesPoolInput.self)!
            let viewModel = EntryEditViewModel(kdbEntry: node, servicesPool: servicesPool, refreshCallback: callback)
            let router = EntryRouter(withResolver: container)
            let view = EntryViewController(viewModel: viewModel, servicesPool: servicesPool)
            viewModel.router = router
            router.viewController = view
            return view
        }

        container.register(EntryViewInput.self) { (resolver, node: Kdb.Group, callback: @escaping () -> Void) in
            let servicesPool = resolver.resolve(ServicesPoolInput.self)!
            let viewModel = EntryAddViewModel(kdbGroup: node, servicesPool: servicesPool, refreshCallback: callback)
            let router = EntryRouter(withResolver: container)
            let view = EntryViewController(viewModel: viewModel, servicesPool: servicesPool)
            viewModel.router = router
            router.viewController = view
            return view
        }
    }
}
