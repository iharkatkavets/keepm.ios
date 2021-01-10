//
//  EntryBaseViewModel.swift
//  iOSApp
//
//  Created by igork on 1/29/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore
import os.log

class EntryBaseViewModel: EntryViewModelInput {
    var router: EntryRouter!
    var defaultStrings = [EntryFieldViewModel]()
    var customStrings = [EntryFieldViewModel]()
    var newStrings = [EntryFieldViewModel]()
    let servicesPool: ServicesPoolInput
    lazy var outLog = OSLog(subsystem: APP_LOG_SUBSYSTEM, category: String(describing: self))
    let refreshCallback: () -> Void

    init(servicesPool: ServicesPoolInput, refreshCallback: @escaping () -> Void) {
        self.servicesPool = servicesPool
        self.refreshCallback = refreshCallback
    }

    func setupDefaultStrings(_ list: [Kdb.StringField]) -> [Kdb.StringField] {
        var copyIn = list
        for key in Kdb.StringField.DefaultKeys.allCases {
            copyIn = substractDefaultString(key.rawValue, list: copyIn)
        }
        return copyIn
    }

    func substractDefaultString(_ key: String, list: [Kdb.StringField]) -> [Kdb.StringField] {
        var copyIn = list
        for (index, model) in copyIn.enumerated() {
            if model.key == key {
                let viewModel = EntryFieldViewModel(stringValue: model, isDeletable: false)
                defaultStrings.append(viewModel)
                copyIn.remove(at: index)
            }
        }
        return copyIn
    }

    func setupCustomStrings(_ list: [Kdb.StringField]) {
        for model in list {
            let viewModel = EntryFieldViewModel(stringValue: model, isDeletable: true)
            customStrings.append(viewModel)
        }
    }

    var allModels: [EntryFieldViewModel] {
        return defaultStrings + customStrings + newStrings
    }

    func copyValueToClipboard(_ viewModel: EntryFieldViewModel) {
        UIPasteboard.general.string = viewModel.stringField.value
    }

    func addCustomValue(_ completion: @escaping (EntryFieldViewModel) -> Void) {
        router.presentScreenToEnterTitle { (title) in
            if title.count > 0 {
                let stringValue = Kdb.StringField(withKey: title)
                let cellViewModel = EntryFieldViewModel(stringValue: stringValue, isDeletable: true)
                self.newStrings.append(cellViewModel)
                completion(cellViewModel)
            }
        }
    }

    func isAddVisible() -> Bool {
        true
    }

    func isSaveVisible() -> Bool {
        false
    }

    func saveChanges(_ list: [EntryFieldViewModel]) {
    }

    func deleteStringField(_ viewModel: EntryFieldViewModel) {
        
    }
}
