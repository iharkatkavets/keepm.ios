//
//  EntryAddViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore 
import os.log

class EntryAddViewModel: EntryBaseViewModel {
    let entry = Kdb.Entry()
    let parentGroup: Kdb.Group

    init(kdbGroup: Kdb.Group,
         servicesPool: ServicesPoolInput,
         refreshCallback: @escaping () -> Void) {
        self.parentGroup = kdbGroup
        entry.add(Kdb.StringField(withKey: Kdb.StringField.DefaultKeys.Title.rawValue))
        entry.add(Kdb.StringField(withKey: Kdb.StringField.DefaultKeys.UserName.rawValue))
        entry.add(Kdb.StringField(withKey: Kdb.StringField.DefaultKeys.Password.rawValue))
        entry.add(Kdb.StringField(withKey: Kdb.StringField.DefaultKeys.URL.rawValue))
        entry.add(Kdb.StringField(withKey: Kdb.StringField.DefaultKeys.Notes.rawValue))
        super.init(servicesPool: servicesPool, refreshCallback: refreshCallback)
        setupDefaultStrings(entry.strings)
    }

    override func isAddVisible() -> Bool {
        true
    }

    override func isSaveVisible() -> Bool {
        false
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

        guard let kdbService = self.servicesPool.kdbServiceAdapter else {
            return
        }

        do {
            parentGroup.add(entry)
            try kdbService.save()
            self.refreshCallback()
        } catch {
            os_log(.error, log: outLog, "can't save changes %{public}@", error as NSError)
        }

        router.close()
    }
}
