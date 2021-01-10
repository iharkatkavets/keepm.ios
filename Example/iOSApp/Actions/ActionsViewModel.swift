//
//  ActionsViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

class ActionsViewModel {
    // MARK: Private
    private let resolver: Resolver

    // MARK: Public
    var router: ActionsRouter!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }
}
