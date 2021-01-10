//
//  Localization.swift
//  IKKeePassCore
//
//  Created by Igor Kotkovets on 7/6/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

extension String {
    public func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

class Localizable {
}

extension Localizable {
    struct Alert {
        static let okAction = "Alert.okAction".localized()
        static let cancelAction = "Alert.cancelAction".localized()
    }
}

extension Localizable {
    struct FilesList {
        static let screenTitle = "FilesList.ScreenTitle".localized()
    }
}
