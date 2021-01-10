//
//  EntryFieldViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 12/29/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore

class EntryFieldViewModel {
    let stringField: Kdb.StringField
    var changedValue: String?
    let isDeletable: Bool

    var key: String? {
        return stringField.key
    }

    var value: String? {
        return stringField.value
    }

    init(stringValue: Kdb.StringField, isDeletable: Bool) {
        self.stringField = stringValue
        self.isDeletable = isDeletable
    }
}
