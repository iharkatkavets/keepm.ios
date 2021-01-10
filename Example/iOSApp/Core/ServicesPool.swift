//
//  ServicesPool.swift
//  Common_iOS
//
//  Created by Igor Kotkovets on 1/9/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore
import RxSwift
import RxCocoa
import Swinject


enum ServiceError: Swift.Error {
    case fileOpened
    case wrongPath
}

protocol ServicesPoolInput {
    func closeKdbFile()
    func startGoogleDriveService(rootViewController: UIViewController) -> GoogleDriveService
    var googleDriveService: GoogleDriveService? { get }
    func startKeyboardService()
    var keyboardService: KeyboardServiceInput? { get }
    func startAppSettingsService() -> AppSettingsService
    var appSettingsService: AppSettingsService? { get }
    func startFirebase()
    func startCredentialsStoreService()
    var credentialsStoreService: CredentialsStore? { get }
    func startKdbServiceWithFileItem(_ fileItem: StorageItem, rootViewController: UIViewController) throws -> KdbServiceAdapterInput
    func stopKdbService()
    var kdbServiceAdapter: KdbServiceAdapterInput? { get }

}

class ServicesPool: ServicesPoolInput {
    private(set) var kdbServiceAdapter: KdbServiceAdapterInput?
    private(set) var googleDriveService: GoogleDriveService?
    private(set) var keyboardService: KeyboardServiceInput?
    private(set) var appSettingsService: AppSettingsService?
    private(set) var firebaseService: FirebaseServiceInput?
    private(set) var credentialsStoreService: CredentialsStore?
    private(set) var errorHandler: ErrorHandlerInput?
    let resolver: Swinject.Resolver

    init(resolver: Swinject.Resolver) {
        self.resolver = resolver
    }



    func closeKdbFile() {
        kdbServiceAdapter = nil
    }

    func startGoogleDriveService(rootViewController: UIViewController) -> GoogleDriveService {
        if let service = googleDriveService {
            return service
        }
        else {
            let appSettings = startAppSettingsService()
            let transferringContextManager = resolver.resolve(TransferringContextManagerInput.self)!
            let service = GoogleDriveService(appSettingsService: appSettings,
                                             transferringContextManager: transferringContextManager,
                                             rootViewController: rootViewController)
            self.googleDriveService = service
            return service
        }
    }

    func startKeyboardService() {
        if keyboardService == nil {
            let service = KeyboardService()
            service.start()
            self.keyboardService = service
        }
    }

    func startAppSettingsService() -> AppSettingsService {
        if let service = appSettingsService {
            return service
        }
        else {
            let service = AppSettingsService()
            service.start()
            self.appSettingsService = service
            return service
        }
    }

    func startFirebase() {
        if firebaseService == nil {
            let service = FirebaseService()
            service.start()
            firebaseService = service
        }
    }

    func startCredentialsStoreService() {
        if credentialsStoreService == nil {
            credentialsStoreService = CredentialsStore()
        }
    }

    func startKdbServiceWithFileItem(_ fileItem: StorageItem, rootViewController: UIViewController) throws -> KdbServiceAdapterInput {
        guard self.kdbServiceAdapter == nil else {
            throw ServiceError.fileOpened
        }

        let service = KdbServiceAdapter(fileItem: fileItem, rootViewController: rootViewController, resolver: resolver)
        self.kdbServiceAdapter = service
        return service
    }

    func stopKdbService() {
        self.kdbServiceAdapter = nil
    }

    func startErrorHandlerWithRootViewController(_ rootViewController: UIViewController) {
        guard let errorHandler = self.errorHandler else {
            return
        }

        self.errorHandler = ErrorHandler(viewController: rootViewController)
    }
}




