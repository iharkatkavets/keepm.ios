//
//  GoogleDriveFetcher.swift
//  iOSApp
//
//  Created by igork on 5/14/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import GTMAppAuth
import os.log

enum GoogleDriveFetchError: Error {
    case canNotFetch
    case fileNotConnectedToGoogleDrive
}

class GoogleDriveFetcher {
    let driveService: GTLRDriveService
    let appSettingsService: AppSettingsService
    let outLog = OSLog(subsystem: APP_LOG_SUBSYSTEM, category: String(describing: GoogleDriveFetcher.self))
    let fields = "kind,nextPageToken,files(mimeType,id,kind,name,trashed,fileExtension,modifiedTime,version)"

    init(driveService: GTLRDriveService, appSettingsService: AppSettingsService) {
        self.driveService = driveService
        self.appSettingsService = appSettingsService
    }

    func fetchDirectory(_ directory: GTLRDrive_File?, completion: @escaping (Result<GTLRDrive_FileList, GoogleDriveFetchError>) -> Void) {
        os_log(.debug, log: self.outLog, "fetchDirectory %s...", directory?.name ?? "")
        let query = GTLRDriveQuery_FilesList.query()
        let folderID = directory?.identifier ?? "root"
        var queryPrefix = ""
        if self.appSettingsService.bool(forKey: .showOnlyKDBFiles) == true {
            queryPrefix = "(fileExtension='kdbx' or mimeType='application/vnd.google-apps.folder') and "
        }

        let root = "\(queryPrefix)'\(folderID)' in parents and trashed=false"
        query.q = root
        query.fields = "kind,nextPageToken,files(mimeType,id,kind,name,trashed,fileExtension,modifiedTime,version)"
        self.driveService.executeQuery(query) { (ticket, result, error) in
            if let list = result as? GTLRDrive_FileList {
                completion(Result.success(list))
            }
            else {
                completion(Result.failure(GoogleDriveFetchError.canNotFetch))
            }
        }
    }

    func fetchRemoteMetadataForFileWithID(_ id: String, completion: @escaping (Result<GTLRDrive_File, GoogleDriveFetchError>) -> Void) {
        os_log(.debug, log: self.outLog, "fetch remote file info...")

        let query = GTLRDriveQuery_FilesGet.query(withFileId: id)
        query.fields = "mimeType,id,kind,name,trashed,fileExtension,modifiedTime,version"
        self.driveService.executeQuery(query) { (ticket, result, error) in
            if let file = result as? GTLRDrive_File {
                os_log(.debug, log: self.outLog, "fetch remote file info... success")
                completion(Result.success(file))
            }
            else {
                os_log(.error, log: self.outLog, "fetch remote file info... failed %@", error! as NSError)
                completion(Result.failure(GoogleDriveFetchError.canNotFetch))
            }
        }
    }
}
