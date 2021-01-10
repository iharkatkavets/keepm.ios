//
//  PrivacyPolicyViewAssembly.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/16/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation


class PrivacyPolicyViewAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PrivacyPolicyViewController.self) { resolver in
            let controller = PrivacyPolicyViewController(resolver: container)
            return controller
        }
    }
}
