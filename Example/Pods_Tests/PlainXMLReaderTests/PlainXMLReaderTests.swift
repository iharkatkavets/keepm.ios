//
//  PlainXMLReaderTests.swift
//  Pods_Tests
//
//  Created by igork on 8.01.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class PlainXMLReaderTests: XCTestCase {

    func testOpenFileLikePlainText() {
        let string = openKdbx(file: "file.kdbx", password: "file")
        // po NSString(string: string!)
        XCTAssertNotNil(string)
    }

    func openKdbx(file: String, password: String) -> String {
        let credentials = KdbCredentials.password(password)
        let url = Bundle(for: PlainXMLReaderTests.self).url(forResource: file, withExtension: nil)!
        let fileHandle = try! FileHandle(forReadingFrom: url)
        let fileInputStream = FileInputStream(withFileHandle: fileHandle)
        let kdbReader = Kdb4Reader(file: fileInputStream)

        let signature = try! kdbReader.readSignature()
        XCTAssertEqual(signature.fileVersionMajor, 1)
        XCTAssertEqual(signature.fileVersionMinor, 1)

        let headers = try! kdbReader.readHeaders()


        let keyBuilder = Kdb4KeyBuilder()
        let masterSeed = try! kdbReader.obtainMasterSeed(from: headers)
        let transformSeed = try! kdbReader.obtainTransformSeed(from: headers)
        let transformRounds = try! kdbReader.obtainTransformRounds(from: headers)
        let aesKey = try! keyBuilder.createMasterKeyWith(credentials: credentials,
                                                        masterSeed: masterSeed,
                                                        transformSeed: transformSeed,
                                                        rounds: transformRounds)
        let encryptionIV = try! kdbReader.obtainEncryptionIV(from: headers)
        let aesStream = try! AesInputStream(with: fileInputStream, key: aesKey, vector: encryptionIV)
        let startBytes = try! kdbReader.obtainStartBytes(from: headers)
        try! kdbReader.verifyStartBytes(inAesStream: aesStream, andCompareWith: startBytes)
        let algorithm = try! kdbReader.obtainCompressionAlgorithm(from: headers)
        let streamId = try! kdbReader.obtainRandomStreamId(from: headers)
        let streamKey = try! kdbReader.obtainProtectedStreamKey(from: headers)
        let generator = try! kdbReader.createRandomGenerator(streamId, withProtected: streamKey)

        var inputStream: KeePassCore.InputStream = HashedBlockInputStream(with: aesStream)
        if algorithm == .gzip {
            inputStream = try! GZipInputStream(with: inputStream)
        }

        let plainData = inputStream.readDataOfLength(5000)
        let string = String(data: plainData, encoding: .utf8)
        return string!
    }

}
