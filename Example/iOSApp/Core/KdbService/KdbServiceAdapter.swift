//
//  KdbServiceAdapter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 6/26/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore
import Swinject

protocol KdbServiceAdapterInput {
    func openFile(_ rootViewController: UIViewController)
    func openWithPassword(_ password: String) throws -> Kdb.Tree
    func createWithPassword(_ password: String) throws -> Kdb.Tree
    func save() throws
}

class KdbServiceAdapter: KdbServiceAdapterInput {
    let service: KdbService
    let fileItem: StorageItem
    let metadataManager = MetadataManager()
    let router: KdbServiceRouter
    var filePath: String { return fileItem.path }
    var tree: Kdb.Tree?
    var userMadeChanges: Bool = false

    public init(fileItem: StorageItem, rootViewController: UIViewController, resolver: Swinject.Resolver) {
        self.service = KdbService(path: fileItem.path)
        self.fileItem = fileItem
        self.router = KdbServiceRouter(withResolver: resolver, rootViewController: rootViewController)
    }

    func canOpen() -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) == false {
            return false
        }

        do {
            let url = URL(fileURLWithPath: filePath)
            let fileHandle = try FileHandle(forReadingFrom: url)
            let fileInputStream = FileInputStream(withFileHandle: fileHandle)
            let signatureReader = KdbSignatureReader()
            let signature = try signatureReader.readSignature(fileInputStream)
            if KDB2_SIGNATURE_UINT32 == signature.kdbVersion {
                return true
            }

            return false
        } catch {
            return false
        }
    }

    func openWith(credentials: KdbCredentials) throws -> Kdb.Tree {
        try service.openWith(credentials: credentials)
    }

    func openWithPassword(_ password: String) throws -> Kdb.Tree {
        let credentials = KdbCredentials.password(password)
        let tree = try openWith(credentials: credentials)
        self.tree = tree

        do {
            //            var metadata = try fileMetadataManager.loadForFileAtURL(self.fileItem.url)
            //            metadata.touchIDEnabled = touchIDOnValue
            //            try fileMetadataManager.metadataManager.save(metadata, forFile: self.document.url)
            //            try self.credentialsStore.saveCredentials(.password(password, file: self.document.name))
        }
        catch {
        }

        return tree
    }

    func createWithPassword(_ password: String) throws -> Kdb.Tree {
        userMadeChanges = true
        let credentials = KdbCredentials.password(password)
        let tree = try service.createWith(credentials: credentials)
        self.tree = tree
        return tree
    }

    func save() throws {
        userMadeChanges = true
        try metadataManager.setFileHasChanges(true, forFile: fileItem.url)
        try service.save()
    }

    func openFile(_ rootViewController: UIViewController) {
        if canOpen() {
            let metadata = try? self.metadataManager.loadMetadataFileForFileAtPath(self.filePath)
            let touchIdEnabled = metadata?.touchIDEnabled ?? false
            router.openDatabaseWithPassword(fileItem, touchIDEnabled: touchIdEnabled) { (tree) in
                if let rootGroup = tree.group {
                    self.router.openKdbTree(rootGroup: rootGroup) {
                    }
                }
            }
        }
        else {
            router.showErrorWithTitle("Can't open file")
        }
    }
}
