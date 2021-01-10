//
//  KdbService.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/9/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import os.log
import CommonCrypto
import KeePassCore


public enum KdbServiceError: Error {
    case canNotOpenFile
    case unsupportedFile
    case wrongPassword
    case internalError
}

protocol KdbServiceInput {
    func openWith(credentials: KdbCredentials) throws -> Kdb.Tree
    func createWith(credentials: KdbCredentials) throws -> Kdb.Tree
    func save() throws
}

open class KdbService: KdbServiceInput {
    let filePath: String
    
    var databaseParameters = DatabaseParameters()
    let outLog = OSLog(subsystem: APP_LOG_SUBSYSTEM, category: "KdbService")
    let metadataManager = MetadataManager()
    
    public init(path: String) {
        filePath = path
    }    
    
    public func openWith(credentials: KdbCredentials) throws -> Kdb.Tree {
        let fileManager = FileManager.default
        self.databaseParameters = DatabaseParameters()
        
        if fileManager.fileExists(atPath: filePath) == false {
            throw KdbServiceError.canNotOpenFile
        }

        do {
            let url = URL(fileURLWithPath: filePath)
            let fileHandle = try FileHandle(forReadingFrom: url)
            let inputStream = FileInputStream(withFileHandle: fileHandle)
            //        let signatureReader = KdbSignatureReader()
            //        let signature = try signatureReader.readSignature(inputStream)
            //        let kdbReader = try createReaderForStream(inputStream, signature: signature)
            let kdbReader = Kdb4Reader(file: inputStream)
            self.databaseParameters = try kdbReader.readWithCredentials(credentials)
            return self.databaseParameters.tree!
        } catch KdbReaderError.startBytesNotEqual {
            throw KdbServiceError.wrongPassword
        } catch {
            throw KdbServiceError.internalError
        }
    }

    public func createWith(credentials: KdbCredentials) throws -> Kdb.Tree {
        let tree = Kdb4TreeTemplate.create()
        self.databaseParameters = DatabaseParameters()
        self.databaseParameters.credentials = credentials
        self.databaseParameters.compressionAlgorithm = .gzip
        self.databaseParameters.tree = tree
        try save()
        os_log(.debug, log: outLog, "created kdbx file at %{public}s", filePath)
        return tree
    }
    
    func createReaderForStream(_ stream: FileInputStream, signature: KdbSignature) throws -> Kdb4Reader {
        guard signature.kdbVersion == KDB2_SIGNATURE_UINT32 else {
            throw KdbServiceError.unsupportedFile
        }

        return Kdb4Reader(file: stream)
    }
    
    public func save() throws {
        do {
            let dataOutputStream = DataOutputStream()
            let kdbWriter = try Kdb4Writer(cachedParameters: self.databaseParameters)
            try kdbWriter.write(dataOutputStream)
            createFileIfNotExists()
            let url = URL(fileURLWithPath: self.filePath)
            let fileHandle = try FileHandle(forWritingTo: url)
            let fileOutputStream = FileOutputStream(with: fileHandle)
            _ = try fileOutputStream.write(dataOutputStream.data)
        } catch {
            os_log(.error, log: outLog, "can't save %{publis}@", error as NSError)
        }
    }

    func createFileIfNotExists() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.filePath) == false {
            if fileManager.createFile(atPath: self.filePath, contents: nil, attributes: nil) == false {
                os_log(.error, log: outLog, "can't create KDB file at path %{public}s", self.filePath)
            }
        }
    }
}
