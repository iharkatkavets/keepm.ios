//
//  NewDatabaseViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Swinject
import Foundation

class NewDatabasePresenter {
    // MARK: Private
    private let resolver: Resolver
    weak var view: NewDatabaseViewInput!
    private let completion: (_ filename: String, _ password: String, _ touchIDOn: Bool) -> Void

    // MARK: Public
    var router: NewDatabaseRouter!
    let metadataManager = MetadataManager()

    var filename = ""
    var password1 = ""
    var password2 = ""
    var touchIDState = false
    var allDataProvided = false

    init(withResolver resolver: Swinject.Resolver, servicesPool: ServicesPoolInput, completion: @escaping (_ filename: String, _ password: String, _ touchIDOn: Bool) -> Void) {
        self.resolver = resolver
        self.completion = completion

        let allowUseTouchID = servicesPool.appSettingsService?.bool(forKey: .allowUseTouchID) ?? false
    }

    func loadInitialState() {
        view.setCreateButtonEnabled(enabled: allDataProvided)
    }

    func acceptPassword1(value: String) {
        password1 = value
        processInputData()
    }

    func acceptPassword2(value: String) {
        password2 = value
        processInputData()
    }

    func acceptFilename(value: String) {
        filename = value
        processInputData()
    }

    func processInputData() {
        self.view.clearEnteringPasswordsError()

        if (filename.count == 0
                || password1.count == 0
                || password2.count == 0) {
            self.allDataProvided = false
        }
        else if (password2 != password1) {
            self.allDataProvided = false
            self.view.showEnteringPasswordsError(text: "Passwords are not equal")
        }
        else {
            self.allDataProvided = true
        }

        self.view.setCreateButtonEnabled(enabled: self.allDataProvided)
    }

    func create() {
        router.dismissScreen {
            var correctedFileName = self.filename
            if correctedFileName.hasSuffix(MetadataManager.kdbxSuffics) == false {
                correctedFileName += MetadataManager.kdbxSuffics
            }

            self.completion(correctedFileName, self.password1, self.touchIDState)
        }
    }

    func cancel() {
        router.dismissScreen { }
    }
}
