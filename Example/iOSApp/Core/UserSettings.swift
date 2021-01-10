//
//  UserSettings.swift
//  IKKeePassCore
//
//  Created by Igor Kotkovets on 7/6/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

protocol UserSettingsInterface {
    var lastUsedFilePath: URL? { get set }
}

class UserSettings: UserSettingsInterface {
    var lastUsedFilePath: URL? {
        get {
            return UserDefaults.standard.value(forKey: "dbPath") as? URL ?? nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "dbPath")
        }
    }
}
