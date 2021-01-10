//
//  GoogleDriveAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Swinject
import KeePassCore


class GoogleDriveAssembly: Assembly {
    func assemble(container: Container) {
        container.register(GoogleDriveViewInput.self) { (resolver) in
            let servicePool = resolver.resolve(ServicesPoolInput.self)!
            let viewModel = GoogleDriveViewModel(servicesPool: servicePool)
            let router = GoogleDriveRouter(withResolver: container)
            let view = GoogleDriveViewController(viewModel: viewModel)
            viewModel.router = router
            router.viewController = view
            return view
        }

        container.register(GoogleDriveViewInput.self) { (resolver, directory: GoogleDriveItem) in
            let servicePool = resolver.resolve(ServicesPoolInput.self)!
            let viewModel = GoogleDriveViewModel(servicesPool: servicePool, rootDirectory: directory)
            let router = GoogleDriveRouter(withResolver: container)
            let view = GoogleDriveViewController(viewModel: viewModel)
            viewModel.router = router
            router.viewController = view
            return view
        }
    }
}
