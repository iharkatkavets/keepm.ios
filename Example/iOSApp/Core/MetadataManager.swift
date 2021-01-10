//
//  FileUtils.swift
//  iOSApp
//
//  Created by igork on 2/13/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift

struct FileMetadataManager {
    static var metaSuffics = ".meta.json"
    static var kdbSuffics = ".kdb"
    static var kdbxSuffics = ".kdbx"

    var metadataPathBuilder: MetadataPathBuilder

    static func nameHasKdbSuffics(_ name: String) -> Bool {
        if name.hasSuffix(kdbSuffics) ||
            name.hasSuffix(kdbxSuffics) {
            return true
        }
        else {
            return false
        }
    }

    init() {
        let appDocumentsURL = AppStorage.documentsDir.url
        metadataPathBuilder = MetadataPathBuilder(rootDirectoryURL: appDocumentsURL)
    }

    let fileManager = FileManager.default

    func metadataFileURLForFile(_ url: URL) -> URL {
        let fileName = url.lastPathComponent
        let paramsName = fileName + ".meta.json"
        let newURL = url.deletingLastPathComponent().appendingPathComponent(paramsName)
        return newURL
    }

    func loadMetadataFileForFileAtPath(_ path: String) throws -> DatabaseMetadata {
        let url = URL(fileURLWithPath: path)
        return try loadMetadataFileForFileAtURL(url)
    }

    func loadMetadataFileForFileAtURL(_ url: URL) throws -> DatabaseMetadata {
        let metadataURL = metadataFileURLForFile(url)
        let data = try Data(contentsOf: metadataURL)
        let jsonDecoder = JSONDecoder()
        let meta = try jsonDecoder.decode(DatabaseMetadata.self, from: data)
        return meta
    }

    func save(_ metadata: DatabaseMetadata, forFileAtPath path: String) throws {
        do {
            let fileUrl = URL(fileURLWithPath: path)
            let metadataURL = metadataFileURLForFile(fileUrl)
            let jsonEncoder = JSONEncoder()
            let data = try jsonEncoder.encode(metadata)
            try data.write(to: metadataURL)
        } catch {
            throw AppError.parseMetadataIssue
        }
    }

    func setDatabaseHasChanges(_ value: Bool, forFileAtPath path: String) throws {
        do {
            let fileUrl = URL(fileURLWithPath: path)
            let metadataURL = metadataFileURLForFile(fileUrl)
            var data = try Data(contentsOf: metadataURL)
            let jsonDecoder = JSONDecoder()
            var meta = try jsonDecoder.decode(DatabaseMetadata.self, from: data)
            meta.hasChanges = value
            let jsonEncoder = JSONEncoder()
            data = try jsonEncoder.encode(meta)
            try data.write(to: metadataURL)
        } catch {
            throw AppError.parseMetadataIssue
        }
    }

    func loadForFileAtPath(_ path: String) throws -> DatabaseMetadata {
        let url = URL(fileURLWithPath: path)
        return try loadForFileAtURL(url)
    }

    func loadForFileAtURL(_ url: URL) throws -> DatabaseMetadata {
        let metadataURL = metadataFileURLForFile(url)
        let data = try Data(contentsOf: metadataURL)
        let jsonDecoder = JSONDecoder()
        let meta = try jsonDecoder.decode(DatabaseMetadata.self, from: data)
        return meta
    }

//    func createMetadataFileForDownloadedItem(_ item: GoogleDriveItem, rawData: Data) -> Observable<Result<Void, AppError>> {
//        return Observable.create { [weak self] observer in
//            guard let `self` = self else {
//                observer.onCompleted()
//                return Disposables.create()
//            }
//
//
//
//            observer.onCompleted()
//            return Disposables.create()
//        }
//    }

//    func createPathForDownloadingItem(_ item: GoogleDriveItem) -> Observable<Result<Void, AppError>> {
//        createMetadataFolderIfNeeded()
//
//        let path = metadataPathBuilder.buildMetadataFilePathFor(item)
//
//    }

    func createMetadataFolderIfNeeded() {
        if fileManager.fileExists(atPath: metadataPathBuilder.metadataDirectoryPath) == false {
            try? fileManager.createDirectory(atPath: metadataPathBuilder.metadataDirectoryPath,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        }
    }
}
