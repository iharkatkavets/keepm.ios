//
//  GoogleDriveDownloadManager.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 4/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import GTMAppAuth
import os.log

enum GoogleDriveDownloadingError: Error {
    case fileExists
    case canNotSaveFile
    case canNotDownload
    case canNotCreateMetadata
}


class GoogleDriveDownloadManager {
    let service: GTLRDriveService
    let metadataManager = MetadataManager()
    let outLog = OSLog(subsystem: "com.katkavets", category: String(describing: GoogleDriveDownloadManager.self))
    let fileManager = FileManager()

    init(service: GTLRDriveService) {
        self.service = service
    }

    func download(_ file: GTLRDrive_File,
                  completion: @escaping (Result<Void, GoogleDriveDownloadingError>) -> Void) {
        os_log(.debug, log: outLog, "download file %s ...", file.name ?? "")
        downloadInternal(file) { (result) in
            if case .success(let url) = result {
                do {
                    try self.metadataManager
                        .createMetadataFileForGoogleDriveFile(file, fileURL: url)
                    completion(Result.success(()))
                } catch {
                    completion(Result.failure(GoogleDriveDownloadingError.canNotCreateMetadata))
                }
            }
            else if case .failure(let error) = result {
                completion(Result.failure(error))
            }
        }
    }

    func downloadInternal(_ file: GTLRDrive_File, completion: @escaping (Result<URL, GoogleDriveDownloadingError>) -> Void) {
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: file.identifier!)
        self.service.executeQuery(query) { (ticket, downloadedOrNil, errorOrNil) in
            if let downloadedData = downloadedOrNil as? GTLRDataObject {
                do {
                    let fileURL = try self.saveRawData(downloadedData.data, name: file.name!)
                    completion(Result.success(fileURL))
                } catch  {
                    completion(Result.failure(GoogleDriveDownloadingError.canNotDownload))
                }
            }
            else {
                completion(Result.failure(GoogleDriveDownloadingError.canNotDownload))
            }
        }
    }

    private func applyAttributesTo(_ targetUrl: URL, usingAttrFrom: GTLRDrive_File) {
        let attributes: [FileAttributeKey : Any] = [FileAttributeKey.modificationDate:usingAttrFrom.modifiedTime?.date as Any]
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: targetUrl.path)
        } catch {
            os_log(.error, log: outLog, "can't apply attributes %@", error as NSError)
        }
    }

    private func saveRawData(_ rawData: Data, name: String) throws -> URL {
        let pathURL = metadataManager.makeLocalURL(name)
        if fileManager.fileExists(atPath: pathURL.path) {
            throw GoogleDriveDownloadingError.fileExists
        }
        do {
            try rawData.write(to: pathURL)
        } catch {
            throw GoogleDriveDownloadingError.canNotSaveFile
        }

        return pathURL
    }
}
