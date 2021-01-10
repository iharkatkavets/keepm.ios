//
//  GoogleDriveUploadManager.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 7/19/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import GTMAppAuth
import os.log

enum GoogleDriveUploadingError: Error {
    case canNotUpload
}

class GoogleDriveUploadManager {
    let service: GTLRDriveService
    let metadataManager = MetadataManager()
    let outLog = OSLog(subsystem: "com.katkavets", category: String(describing: GoogleDriveUploadManager.self))

    init(service: GTLRDriveService) {
        self.service = service
    }

    func upload(_ metadata: GoogleDriveFileMetadata,
                completion: @escaping (Result<Void, GoogleDriveUploadingError>) -> Void) {
        uploadInternal(metadata) { (result) in
            if case .success(let gDriveFile) = result {
                do {
                    try self.metadataManager
                        .updateMetadataFileForGoogleDriveFile(gDriveFile,
                                                              localFileURL: metadata.localFileURL)
                } catch {
                    completion(Result.failure(GoogleDriveUploadingError.canNotUpload))
                }
            }
        }
    }

    func uploadInternal(_ metadata: GoogleDriveFileMetadata, completion: @escaping (Result<GTLRDrive_File, GoogleDriveUploadingError>) -> Void) {
        os_log(.debug, log: self.outLog, "upload file to remote...")

        do {
            let data = try Data(contentsOf: metadata.localFileURL)
            let gFile = GTLRDrive_File()
            let mimeType = metadata.mimeType ?? ""
            let uploadParameters = GTLRUploadParameters(data: data, mimeType: mimeType)
            let query = GTLRDriveQuery_FilesUpdate.query(withObject: gFile, fileId: metadata.fileId, uploadParameters: uploadParameters)
            query.fields = "mimeType,id,kind,name,trashed,fileExtension,modifiedTime,version"

            self.service.executeQuery(query) { (ticket, updatedFileOrNil, errorOrNil) in
                if let error = errorOrNil {
                    os_log(.error, log: self.outLog, "upload file to remote... failed")
                    completion(Result.failure(GoogleDriveUploadingError.canNotUpload))
                }
                else if let file = updatedFileOrNil as? GTLRDrive_File {
                    os_log(.debug, log: self.outLog, "upload file to remote... success")
                    completion(Result.success(file))
                }
                else {
                    completion(Result.failure(GoogleDriveUploadingError.canNotUpload))
                }
            }
        }
        catch {
            os_log(.error, log: self.outLog, "upload file to remote... failed %{public}@", error as NSError)
            completion(Result.failure(GoogleDriveUploadingError.canNotUpload))
        }
    }
}
