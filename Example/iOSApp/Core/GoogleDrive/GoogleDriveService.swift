//
//  GoogleDriveService.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import GTMAppAuth
import os.log

enum GoogleDriveSyncError: Error {
    case fileConfict
}

enum GoogleDriveServiceError: Error {
    case signInError
    case fetchDirectoryError
    case downloadFileError(_: GoogleDriveDownloadingError)
    case fetchFileInfoError
    case syncConflictError
    case uploadFileError
}

class GoogleDriveService: NSObject {
    var service: GTLRDriveService?
    let outLog = OSLog(subsystem: "com.katkavets.kdbxapp", category: "GoogleDriveService")
    var isSignedIn: Bool {
        return service != nil
    }
    let appSettingsService: AppSettingsService
    let metadataManager = MetadataManager()
    var downloadManager: GoogleDriveDownloadManager!
    var uploadManager: GoogleDriveUploadManager!
    let authorizationManager = GoogleDriveAuthorizationManager()
    var fetchManager: GoogleDriveFetcher!
    let transferringContextManager: TransferringContextManagerInput
    weak var rootViewController: UIViewController?
    lazy var createManagers = { (service: GTLRDriveService) -> Void in
        self.service = service
        self.fetchManager = GoogleDriveFetcher(driveService: service, appSettingsService: self.appSettingsService)
        self.downloadManager = GoogleDriveDownloadManager(service: service)
        self.uploadManager = GoogleDriveUploadManager(service: service)
    }
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init(appSettingsService: AppSettingsService,
         transferringContextManager: TransferringContextManagerInput,
         rootViewController: UIViewController) {
        os_log(.info, log: self.outLog, "init")
        self.appSettingsService = appSettingsService
        self.transferringContextManager = transferringContextManager
        self.rootViewController = rootViewController
    }

    func signInUsingViewController(_ viewController: UIViewController,
                                   completion: @escaping (Result<Void, GoogleDriveServiceError>) -> Void) {
        authorizationManager.signInWithPresentationViewController(viewController) { (result) in
            if case .success(let service) = result {
                self.createManagers(service)
                completion(Result.success(()))
            }
            else if case .failure = result {
                completion(Result.failure(GoogleDriveServiceError.signInError))
            }
        }
    }

    func canSignInSilent() -> Bool {
        return authorizationManager.canSignInSilent()
    }

    func signInSilent(completion: @escaping (Result<Void, GoogleDriveServiceError>) -> Void) {
        authorizationManager.signInSilent { (result) in
            if case .success(let service) = result {
                self.createManagers(service)
                completion(Result.success(()))
            }
            else if case .failure = result {
                completion(Result.failure(GoogleDriveServiceError.signInError))
            }
        }
    }
    
    func fetchDirectory(_ directory: GTLRDrive_File?,
                        completion: @escaping (Result<[GoogleDriveItem], GoogleDriveServiceError>) -> Void) {
        fetchManager!.fetchDirectory(directory) { result in
            if case .success(let inList) = result {
                var outList = [GoogleDriveItem]()
                if let gFiles = inList.files {
                    let displayItems = gFiles.map {
                        GoogleDriveItem($0)
                    }
                    outList.append(contentsOf: displayItems)
                }
                completion(Result.success(outList))
            }
            else if case .failure = result {
                completion(Result.failure(GoogleDriveServiceError.fetchDirectoryError))
            }
        }
    }

    func download(_ file: GoogleDriveItem, completion: @escaping (Result<Void, GoogleDriveServiceError>) -> Void) {
        downloadManager.download(file.model) { (result) in
            if case .success = result {
                completion(Result.success(()))
            }
            else if case .failure(let error) = result {
                completion(Result.failure(GoogleDriveServiceError.downloadFileError(error)))
            }
        }
    }

    func fetchFile(_ file: StorageItem, completion: @escaping (Result<GoogleDriveItem, GoogleDriveServiceError>) -> Void) {
        do {
            let url = file.url
            let transferringContext = transferringContextManager.createContentForURL(url)
            let metadata = try metadataManager.loadGoogleDriveMetadataForFileAt(url)
            let fileId = metadata.fileId
            fetchManager.fetchRemoteMetadataForFileWithID(fileId) { (result) in
                if case .success(let item) = result {
                    completion(Result.success(GoogleDriveItem(item)))
                }
                else if case .failure = result {
                    completion(Result.failure(GoogleDriveServiceError.fetchFileInfoError))
                }
            }
        } catch {
            completion(Result.failure(GoogleDriveServiceError.fetchDirectoryError))
        }
    }

    func synchronizeFile(_ file: StorageItem, vc: UIViewController) {
        let url = file.url
        guard (transferringContextManager.fetchContextFor(url)) == nil else {
            os_log(.debug, log: self.outLog, "file is already syncing... skip")
            return
        }

        do {
            let metadata = try metadataManager.loadGoogleDriveMetadataForFileAt(url)
            let transferringContext = transferringContextManager.createContentForURL(url)
            let fileId = metadata.fileId
            os_log(.debug, log: self.outLog, "sync %s started...", fileId)

            signInUsingViewController(vc) { (result) in
                self.fetchManager.fetchRemoteMetadataForFileWithID(fileId) { (result) in
                    if case .success(let item) = result {
                        self.synchronizeFile(item, metadata: metadata) { (result) in
                            os_log(.debug, log: self.outLog, "...sync %s completed", fileId)
                            self.transferringContextManager.removeContext(transferringContext)
                        }
                    }
                    else if case .failure = result {
                        os_log(.error, log: self.outLog, "...sync %s failed", fileId)
                    }
                }
            }
        } catch {
        }
    }

    private func synchronizeFile(_ gdrive: GTLRDrive_File, metadata: GoogleDriveFileMetadata, completion: @escaping (Result<Void,  GoogleDriveServiceError>) -> Void) {
        let localFileHasChanges = metadata.hasChanges;
        let localAndRemoteFilesVersionsSame = gdrive.version?.int64Value == metadata.fileVersion

        if localFileHasChanges && localAndRemoteFilesVersionsSame {
            return self.uploadManager.upload(metadata) { (result) in
                if case .success = result {
                    completion(Result.success(()))
                }
                else if case .failure = result {
                    completion(Result.failure(GoogleDriveServiceError.uploadFileError))
                }
            }
        }
        else if !localFileHasChanges && !localAndRemoteFilesVersionsSame {
            return self.downloadManager.download(gdrive) { (result) in
                if case .success = result {
                    completion(Result.success(()))
                }
                else if case .failure(let error) = result {
                    completion(Result.failure(GoogleDriveServiceError.downloadFileError(error)))
                }
            }
        }
        else if localAndRemoteFilesVersionsSame {
            completion(Result.success(()))
        }
        else {
            completion(Result.failure(GoogleDriveServiceError.syncConflictError))
        }

    }

    private func signIn(completion: @escaping (Result<Void, GoogleDriveServiceError>) -> Void) {
        if isSignedIn {
            return completion(Result.success(()))
        }
        else if canSignInSilent() {
            return signInSilent(completion: completion)
        }
        else if let rootViewController = self.rootViewController {
            return signInUsingViewController(rootViewController, completion: completion)
        }
        else {
            return completion(Result.failure(GoogleDriveServiceError.signInError))
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance()?.signOut()
    }
}
