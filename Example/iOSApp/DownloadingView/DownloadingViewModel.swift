//
//  DownloadingViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

class DownloadingViewModel {
    // MARK: Private
    private let resolver: Resolver

    // MARK: Public
    var router: DownloadingViewRouter!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }
}
