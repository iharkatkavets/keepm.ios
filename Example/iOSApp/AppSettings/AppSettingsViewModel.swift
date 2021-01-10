//
//  AppSettingsViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/29/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

class AppSettingsViewModel {
    // MARK: Private
    private let resolver: Resolver

    // MARK: Public
    var router: AppSettingsViewRouter!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }

    func cellViewModels() -> Observable<[AppSettingsCellViewModel]> {
        return Observable.create { [weak self] observer in
            guard let servicesPool = self?.resolver.resolve(ServicesPoolInput.self),
                let settingsService = servicesPool.appSettingsService else {
                observer.onCompleted()
                return Disposables.create()
            }

            let cell0 = AppSettingsCellViewModel()
            cell0.switchIsHidden = false
            cell0.switchIsOn = settingsService.bool(forKey: AppSettingsKey.allowUseTouchID)
            cell0.title = "Allow use Touch ID"
            cell0.switchToggled = { value in
                settingsService.set(value, forKey: AppSettingsKey.allowUseTouchID)
            }

            let list = [cell0]
            observer.onNext(list)

            observer.onCompleted()
            return Disposables.create()
        }
    }
}
