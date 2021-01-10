//
//  PasswordViewModel.swift
//  iOSApp
//
//  Created by igork on 2/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation
import KeePassCore

class PasswordViewModel {
    private let resolver: Resolver
    var router: PasswordRouter!
    let servicesPool: ServicesPoolInput
    let document: StorageItem
    let passwordVariable = BehaviorRelay<String?>(value: nil)
    var passwordObservable: Observable<String?> { return passwordVariable.asObservable() }
    var isOpenButtonEnabled: Observable<Bool> {
        return passwordObservable.map {
            guard let value = $0 else {
                return false
            }
            return value.lengthOfBytes(using: .utf8) > 0
        }
    }
    let completion: (Kdb.Tree) -> Void
    var processingVisible = BehaviorSubject<Bool>(value: false)
    var processingHidden: Observable<Bool> {
        return processingVisible.asObservable().map { !$0 }
    }
    var touchIdControlHidden: BehaviorSubject<Bool>
    var touchIDOnSubject: BehaviorSubject<Bool>
    private let metadataManager = MetadataManager()
    private let credentialsStore = CredentialsStore()

    init(withResolver resolver: Swinject.Resolver,
         servicesPool: ServicesPoolInput,
         document: StorageItem,
         touchIDEnabled: Bool,
         completion: @escaping (Kdb.Tree) -> Void) {
        self.resolver = resolver
        self.servicesPool = servicesPool
        self.document = document
        self.completion = completion
        let allowUseTouchID = servicesPool.appSettingsService?.bool(forKey: .allowUseTouchID) ?? false
        self.touchIdControlHidden = BehaviorSubject(value: !allowUseTouchID)
        self.touchIDOnSubject = BehaviorSubject(value: allowUseTouchID && touchIDEnabled)
    }

    func open() {
        guard let kdbServiceAdapter = self.servicesPool.kdbServiceAdapter,
            let password = passwordVariable.value else {
            return
        }

        do {
            self.processingVisible.onNext(true)
            let tree = try kdbServiceAdapter.openWithPassword(password)

//            let metadata = try self.metadataManager.loadForFileAtURL(self.document.url)
//            try self.metadataManager.save(metadata, forFile: self.document.url)
//            try self.credentialsStore.saveCredentials(.password(password, file: self.document.name))
            router.close()
            completion(tree)
        } catch KdbServiceError.wrongPassword {
            self.processingVisible.onNext(false)
            self.router.presentError("Can't open database", message: "Wrong password")
        } catch {
            self.processingVisible.onNext(false)
            self.router.presentError("Can't open database", message: "Unsupported file or file corrupted")
        }
    }

    func cancelOpen() {
        self.servicesPool.stopKdbService()
        router.close()
    }
}
