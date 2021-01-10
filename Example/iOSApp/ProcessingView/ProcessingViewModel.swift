//
//  ProcessingViewModel.swift
//  iOSApp
//
//  Created by igork on 2/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation


class ProcessingViewModel {
    // MARK: Private
    private let resolver: Resolver

    // MARK: Public
    var router: ProcessingViewRouter!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }
}
