//
//  FilesListAssembly.swift
//  IKKeePassCore
//
//  Created by Igor Kotkovets on 7/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Swinject

class FilesListAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FilesListViewInput.self) { resolver in
            let router = FilesListRouter(withResolver: container)
            let servicesPool = resolver.resolve(ServicesPoolInput.self)
            let presenter = FilesListPresenter(servicesPool: servicesPool!)
            let transferringContextManager = resolver.resolve(TransferringContextManagerInput.self)!
            presenter.router = router
            let view = FilesListViewController(servicesPool: servicesPool!,
                                               transferringContextManager: transferringContextManager)
            view.output = presenter
            presenter.view = view
            router.viewController = view
            return view
        }
    }
}
