//
//  FilesListViewModel.swift
//  IKKeePassCore
//
//  Created by Igor Kotkovets on 7/6/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore
import os.log
import LocalAuthentication

struct StorageDisplayItem {
    let document: StorageItem
    var servicesPool: ServicesPoolInput
    let metadata: BaseFileMetadata?

    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        return df
    }()

    var name: String {
        return document.name
    }

    var dateString: String {
        guard let date = metadata?.modifyDate else {
            return "not modified"
        }
        return dateFormatter.string(from: date)
    }
}

class FilesListPresenter: FilesListViewOutput {
    enum AuthError: Swift.Error {
        case error
        case internalError
        case cantAuthorize
    }

    var router: FilesListRouter!
    weak var view: FilesListViewInput!
    private lazy var fileManager: FileManager = .default
    let documentsManager: AppStorageInput
    let servicesPool: ServicesPoolInput
    let currentDirectory: StorageItem
    let fileManagar = FileManager.default
    lazy var outLog = OSLog(subsystem: APP_LOG_SUBSYSTEM, category: String(describing: self))
    private let metadataManager = MetadataManager()
    private let credentialsStore = CredentialsStore()
    private let metadataPathBuilder: MetadataPathBuilder


    init(rootDirectory: StorageItem = AppStorage.documentsDir, servicesPool: ServicesPoolInput) {
        self.currentDirectory = rootDirectory
        self.documentsManager = AppStorage(directory: rootDirectory)
        print(rootDirectory.path)
        self.servicesPool = servicesPool
        metadataPathBuilder = MetadataPathBuilder()
    }

    func didTriggerViewDidLoad() {
        presentDirectoryContent()
    }

    private func presentDirectoryContent() {
        let directoryItems = self.documentsManager.contentOfDirectory(self.currentDirectory.url)
        let metadataFilesFilter = MetadataFilesFilter(metaSuffix: metadataFilesSuffix)
        let displayModels = metadataFilesFilter.perform(directoryItems).map(self.createDisplayItems)
        view.displayContentItems(displayModels)
        view.displayTitle(currentDirectory.name)
    }

    func createDisplayItems(_ item: StorageItem) -> StorageDisplayItem {
        let metadata = try? metadataManager.loadMetadataFileForFileAtURL(item.url)
        let doc = StorageDisplayItem(document: item,
                                      servicesPool: servicesPool,
                                      metadata: metadata)
        return doc
    }

    func openFile(_ displayItem: StorageDisplayItem, viewController: UIViewController) {
        let fileItem = displayItem.document
        do {
            let kdbAdapter = try servicesPool.startKdbServiceWithFileItem(fileItem, rootViewController: viewController)
            kdbAdapter.openFile(viewController)
        } catch {
            if case ServiceError.fileOpened = error {
                router.presentError("File already opened")
            }
        }
    }

    func allowUserTouchID() -> Bool {
        return self.servicesPool.appSettingsService?.bool(forKey: .allowUseTouchID) ?? false
    }

    func authorizeUsingTouchID(_ completion: @escaping (Result<Void, AuthError>) -> Void) {
        let authContext = LAContext()
        var error: NSError?
        if authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Log in to your account"
            authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                if success {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    DispatchQueue.main.async {
                        completion(.failure(.error))
                    }
                }
            }
        }
        else {
            completion(.failure(.cantAuthorize))
        }
    }

    func deleteFile(_ displayItem: StorageDisplayItem) {
        self.router.presentDeleteFileAlert(filename: displayItem.name) { (action) in
            if case .delete = action {
                self.documentsManager.remove(displayItem.document)
                self.view.deleteItem(displayItem)
            }
        }
    }

    func createFile(viewController: UIViewController) {
        self.router.presentScreenToEnterNewDatabaseParameters { (filename, password, touchIDOnValue) in
            let fileURL = self.currentDirectory.url.appendingPathComponent(filename)
            let relativePath = fileURL.pathWithDeletingDocumentsDir()
            let metadata = LocalFileMetadata(relativePath: relativePath)
            let fileItem = StorageItem(url: fileURL)

            do {
                let kdbAdapter = try self.servicesPool.startKdbServiceWithFileItem(fileItem, rootViewController: viewController)
                let tree = try kdbAdapter.createWithPassword(password)
                try self.metadataManager.save(metadata, forFile: fileURL)
                try self.credentialsStore.saveCredentials(.password(password, file: filename))
                if let rootGroup = tree.group {
                    self.router.openKdbTree(rootGroup: rootGroup) {
                        self.presentDirectoryContent()
                    }
                } 
            }
            catch {
                print("can't open file \(error)")
                self.servicesPool.closeKdbFile()
            }
        }
    }

    func refreshContent() {
        self.presentDirectoryContent()
    }

    func didTriggerOpenInfo() {
        
    }
}
