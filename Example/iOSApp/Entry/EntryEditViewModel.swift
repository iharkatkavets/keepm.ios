//
//  TreeViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/25/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore
import os.log

class EntryEditViewModel: EntryBaseViewModel {
    let entry: Kdb.Entry

    init(kdbEntry: Kdb.Entry, servicesPool: ServicesPoolInput, refreshCallback: @escaping () -> Void) {
        self.entry = kdbEntry
        super.init(servicesPool: servicesPool, refreshCallback: refreshCallback)
        var allStrings = entry.strings
        allStrings = setupDefaultStrings(allStrings)
        setupCustomStrings(allStrings)
    }

    override func isAddVisible() -> Bool {
        false
    }

    override func isSaveVisible() -> Bool {
        true
    }

    override func saveChanges(_ list: [EntryFieldViewModel]) {
        for viewModel in list {
            for stringField in entry.strings {
                if viewModel.stringField === stringField {
                    stringField.value = viewModel.changedValue
                }
            }
        }

        for newStringField in newStrings {
            if let key = newStringField.key {
                entry.add(Kdb.StringField(withKey: key, value: newStringField.changedValue, isProtected: false))
            }
        }

        guard let kdbService = self.servicesPool.kdbServiceAdapter else { return }

        do {
            try kdbService.save()
            self.refreshCallback()
        } catch {
            os_log(.info, log: outLog, "can't save changes %{public}@", error as NSError)
        }

        router.close()
    }

    override func deleteStringField(_ viewModel: EntryFieldViewModel) {
        for (index, customStringField) in customStrings.enumerated() {
            if viewModel.stringField === customStringField.stringField {
                entry.remove(viewModel.stringField)
                customStrings.remove(at: index)
                return
            }
        }


    }
}
