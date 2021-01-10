//
//  FileMetadata.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 6/17/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

enum ContainerType: Int, Codable {
    case local = 0x00
    case googleDrive = 0x01
}



protocol BaseFileMetadata: Versionable {
    var type: ContainerType { get }
    var relativePath: String { get set }
    var hasChanges: Bool { get set }
    var info: String? { get set }
    var touchIDEnabled: Bool { get set }
    var modifyDate: Date? { get set }
}

extension BaseFileMetadata {
    var localFileURL: URL {
        return AppStorage.documentsDir.url.appendingPathComponent(relativePath)
    }
}

class MetadataContainerType: Decodable {
    var type: ContainerType

    init(type: ContainerType) {
        self.type = type
    }
}



class LocalFileMetadata: BaseFileMetadata {
    var type: ContainerType = .local
    var relativePath: String
    var hasChanges: Bool = false
    var info: String?
    var touchIDEnabled: Bool = false
    var modifyDate: Date? = nil

    var version: Version = LocalFileMetadata.version

    enum Versions: Int {
        case v1 = 1
    }

    static var version: Version = Versions.v1.rawValue
    static var migrations: [Migration] = []

    init(relativePath: String) {
        self.relativePath = relativePath
    }
}



class GoogleDriveFileMetadata: BaseFileMetadata {
    var type: ContainerType = .googleDrive
    var relativePath: String
    var hasChanges: Bool = false
    var info: String?
    var touchIDEnabled: Bool = false
    var modifyDate: Date? = nil

    var version: Version = GoogleDriveFileMetadata.version

    enum Versions: Int {
        case v1 = 1
    }

    static var version: Version = Versions.v1.rawValue
    static var migrations: [Migration] = []

    var mimeType: String?
    var fileId: String
    var fileVersion: Int64
    var syncDate: Date

    init(fileId: String, syncDate: Date, fileVersion: Int64, relativePath: String) {
        self.fileId = fileId
        self.syncDate = syncDate
        self.relativePath = relativePath
        self.fileVersion = fileVersion
    }
}
