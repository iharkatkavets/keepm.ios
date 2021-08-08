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

class AppSettingsPresenter {
    // MARK: Private
    private let resolver: Resolver
    var view: AppSettingsViewInput!

    // MARK: Public
    var router: AppSettingsViewRouter!

    init(withResolver resolver: Swinject.Resolver) {
        self.resolver = resolver
    }
    
    func didTriggerViewWillAppear() {
        guard let servicesPool = self.resolver.resolve(ServicesPoolInput.self),
            let settingsService = servicesPool.appSettingsService else {
            return
        }
        
        let cell0 = AppSettingsModel()
        cell0.boolValue = settingsService.bool(forKey: AppSettingsKey.allowUseTouchID)
        cell0.title = "Allow use Touch ID"
        cell0.boolValueChangedHandler = { value in
            settingsService.set(value, forKey: AppSettingsKey.allowUseTouchID)
        }

        view.displaySettingsList([cell0])
    }
}
