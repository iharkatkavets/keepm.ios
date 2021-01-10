//
//  GoogleDriveSettingsAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Swinject
import KeePassCore


class GoogleDriveSettingsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(GoogleDriveSettingsViewInput.self) { (resolver) in
            let servicesPool = resolver.resolve(ServicesPoolInput.self)!
            let view = GoogleDriveSettingsViewController(servicesPool: servicesPool)
//            viewModel.router = router
//            router.viewController = view
            return view
        }
    }
}
