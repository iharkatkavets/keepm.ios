//
//  KdbTreeAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/25/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Swinject
import KeePassCore

class GroupListAssembly: Assembly {
    func assemble(container: Container) {
        container.register(GroupListViewInput.self) { (resolver, node: Kdb.Group, refreshCallback: @escaping () -> Void) in
            let servicesPool = resolver.resolve(ServicesPoolInput.self)
            let viewModel = GroupListPresenter(kdbGroup: node, servicesPool: servicesPool!, refreshCallback: refreshCallback)
            let router = GroupListRouter(withResolver: container)
            let view = GroupListViewController(viewModel: viewModel)
            viewModel.view = view
            viewModel.router = router
            router.viewController = view
            return view
        }
    }
}
