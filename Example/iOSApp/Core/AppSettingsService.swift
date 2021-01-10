//
//  AppSettingsService.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import os.log


enum AppSettingsKey: String {
    case showOnlyKDBFiles
    case privacyPolicyAccepted
    case allowUseTouchID
}

class AppSettingsService {
    private let userDefaults = UserDefaults.standard
    private let outLog = OSLog(subsystem: APP_LOG_SUBSYSTEM, category: "AppSettingsService")
    private let internalQueue: DispatchQueue = DispatchQueue(label:"LockingQueue")


    init() {

    }

    func start() {
        internalQueue.sync {
            setupInitialValuesIfNotSetted()
        }
    }

    func setupInitialValuesIfNotSetted() {
        if userDefaults.bool(forKey: "settingsDidSetup") == false {
            set(true, forKey: .showOnlyKDBFiles)
            userDefaults.set(true, forKey: "settingsDidSetup")
        }
    }

    func set(_ value: Bool, forKey: AppSettingsKey) {
        self.userDefaults.set(value, forKey: forKey.rawValue)
    }

    func bool(forKey key: AppSettingsKey) -> Bool {
        self.userDefaults.bool(forKey: key.rawValue)
    }
}
