//
//  GoogleDriveItem.swift
//  iOSApp
//
//  Created by igork on 5/14/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

struct GoogleDriveItem {
    let model: GTLRDrive_File
    let fileMetadata: GoogleDriveFileMetadata?

    var name: String? {
        return model.name
    }

    var isDirectory: Bool {
        if model.mimeType == "application/vnd.google-apps.folder" {
            return true
        }
        else {
            return false
        }
    }

    var isKDBXFile: Bool {
        if model.fileExtension == "kdb" ||
        model.fileExtension == "kdbx" {
            return true
        }
        else {
            return false
        }
    }

    init(_ item: GTLRDrive_File, fileMetadata: GoogleDriveFileMetadata? = nil) {
        self.model = item
        self.fileMetadata = fileMetadata
    }
}
