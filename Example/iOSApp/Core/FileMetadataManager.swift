//
//  FileUtils.swift
//  iOSApp
//
//  Created by igork on 2/13/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import os.log

import GoogleAPIClientForREST
import GTMSessionFetcher

enum MetadataManagerError: Error {
    case unknownType
    case versionIssue
}

class MetadataManager {
    static var kdbSuffics = ".kdb"
    static var kdbxSuffics = ".kdbx"

    var metadataPathBuilder = MetadataPathBuilder()
    let outLog = OSLog(subsystem: APP_LOG_SUBSYSTEM, category: String(describing: MetadataManager.self))

    static func nameHasKdbSuffics(_ name: String) -> Bool {
        if name.hasSuffix(kdbSuffics) ||
            name.hasSuffix(kdbxSuffics) {
            return true
        }
        else {
            return false
        }
    }

    let fileManager = FileManager.default

    init() {
    }

    func makeLocalURL(_ name: String) -> URL {
        return URL(fileURLWithPath: AppStorage.documentsDir.path).appendingPathComponent(name)
    }

    func loadMetadataFileForFileAtPath(_ path: String) throws -> BaseFileMetadata? {
        let url = URL(fileURLWithPath: path)
        return try loadMetadataFileForFileAtURL(url)
    }

    func loadMetadataFileForFileAtURL(_ url: URL) throws -> BaseFileMetadata {
        do {
            let metadataURL = metadataPathBuilder.createMetadataFileURLForFileURL(url)
            let data = try Data(contentsOf: metadataURL)
            let meta = try decode(data)
            return meta
        } catch {
            os_log(.error, log: outLog, "can't read metadata %{public}@", error as NSError)
            throw MetadataManagerError.versionIssue
        }
    }

    func save(_ metadata: GoogleDriveFileMetadata, forFile url: URL) throws {
        do {
            let metadataURL = metadataPathBuilder.createMetadataFileURLForFileURL(url)
            let data = try encode(metadata)
            try data.write(to: metadataURL)
        } catch {
            throw MetadataManagerError.versionIssue
        }
    }

    func save(_ metadata: LocalFileMetadata, forFile url: URL) throws {
        do {
            let metadataURL = metadataPathBuilder.createMetadataFileURLForFileURL(url)
            let data = try encode(metadata)
            try data.write(to: metadataURL)
        } catch {
            throw MetadataManagerError.versionIssue
        }
    }

    func setFileHasChanges(_ value: Bool, forFile url: URL) throws {
        do {
            let metadataURL = metadataPathBuilder.createMetadataFileURLForFileURL(url)
            let readData = try Data(contentsOf: metadataURL)
            var metadata = try decode(readData)
            metadata.hasChanges = value
            metadata.modifyDate = Date()
            let writeData = try encode(metadata)
            try writeData.write(to: metadataURL)
        } catch {
            throw MetadataManagerError.versionIssue
        }
    }

    func loadForFileAtURL(_ url: URL) throws -> BaseFileMetadata {
        let metadataURL = metadataPathBuilder.createMetadataFileURLForFileURL(url)
        let data = try Data(contentsOf: metadataURL)
        let model = try decode(data)
        return model
    }

    func loadGoogleDriveMetadataForFileAt(_ url: URL) throws -> GoogleDriveFileMetadata {
        let metadataFileURL = metadataPathBuilder.createMetadataFileURLForFileURL(url)
        let data = try Data(contentsOf: metadataFileURL)
        let model = try VersionableDecoder().decode(data, type: GoogleDriveFileMetadata.self)
        return model
    }

    func createMetadataFileForGoogleDriveFile(_ item: GTLRDrive_File, fileURL: URL) throws {
        do {
            let metadataFileURL = self.metadataPathBuilder.createMetadataFileURLForFileURL(fileURL)
            let fileMetadata = try self.createMetadataFile(item, fileURL: fileURL)
            try self.saveMetadataToFile(fileMetadata, at: metadataFileURL)
        }
        catch {
            throw MetadataManagerError.versionIssue
        }
    }

    func updateMetadataFileForGoogleDriveFile(_ file: GTLRDrive_File, localFileURL: URL) throws {
        let metadataFileURL = self.metadataPathBuilder.createMetadataFileURLForFileURL(localFileURL)
        do {
            let metadata = try self.loadGoogleDriveMetadataForFileAt(localFileURL)

            let now = Date()
            metadata.hasChanges = false
            metadata.syncDate = now
            metadata.fileVersion = try file.version.orThrow(MetadataManagerError.versionIssue).int64Value
            try self.save(metadata, forFile: metadata.localFileURL)

            try self.saveMetadataToFile(metadata, at: metadataFileURL)
        }
        catch {
            throw MetadataManagerError.versionIssue
        }
    }

    func createMetadataFile(_ item: GTLRDrive_File, fileURL: URL) throws -> GoogleDriveFileMetadata {
        let now = Date()
        let relativePath = fileURL.pathWithDeletingDocumentsDir()
        let fileMetadata =
            GoogleDriveFileMetadata(fileId: item.identifier!,
                                    syncDate: now,
                                    fileVersion: try item.version.orThrow(MetadataManagerError.versionIssue).int64Value,
                                    relativePath: relativePath)
        fileMetadata.mimeType = item.mimeType
        fileMetadata.syncDate = now
        return fileMetadata
    }

    func saveMetadataToFile(_ fileMetadata: GoogleDriveFileMetadata, at url: URL) throws {
        let data = try encode(fileMetadata)
        try data.write(to: url)
    }

    public func decode(_ data: Data) throws -> BaseFileMetadata {
        let decoder = JSONDecoder()
        let metadataContainer = try decoder.decode(MetadataContainerType.self, from: data)

        switch metadataContainer.type {
        case .local:
            return try VersionableDecoder().decode(data, type: LocalFileMetadata.self)
        case .googleDrive:
            return try VersionableDecoder().decode(data, type: GoogleDriveFileMetadata.self)
        }
    }

    private func encode(_ metadata: BaseFileMetadata) throws -> Data {
        let jsonEncoder = JSONEncoder()
        if let googleDriveMetadata = metadata as? GoogleDriveFileMetadata {
            return try jsonEncoder.encode(googleDriveMetadata)
        }
        else if let localFileMetadata = metadata as? LocalFileMetadata {
            return try jsonEncoder.encode(localFileMetadata)
        }
        else {
            throw MetadataManagerError.unknownType
        }
    }
}
