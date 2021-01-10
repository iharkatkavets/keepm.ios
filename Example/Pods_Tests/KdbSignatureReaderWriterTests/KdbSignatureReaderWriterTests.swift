//
//  KdbSignatureReaderWriterTests.swift
//  Pods_Tests
//
//  Created by igork on 7.01.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class KdbSignatureReaderTests: XCTestCase {
    let signatureReader = KdbSignatureReader()
    
    func testThatReadsSignatureV2() throws {
        var kdbxFileSignature = Data(hex: "03d9 a29a 67fb 4bb5 0100 0300")!
        var inputStream = DataInputStream(withData: kdbxFileSignature)
        let signature0 = self.signatureReader.readSignature(inputStream)
        XCTAssertEqual(KdbSignature.v2(majorFileVersion: 3, minorFileVersion: 1), signature0)

        kdbxFileSignature = Data(hex: "03d9 a29a 67fb 4bb5 0100 0000")!
        inputStream = DataInputStream(withData: kdbxFileSignature)
        let signature1 = self.signatureReader.readSignature(inputStream)
        XCTAssertEqual(KdbSignature.v2(majorFileVersion: 0, minorFileVersion: 1), signature1)

        kdbxFileSignature = Data(hex: "03d9 a29a 67fb 4bb5 ffff ffff")!
        inputStream = DataInputStream(withData: kdbxFileSignature)
        let signature2 = self.signatureReader.readSignature(inputStream)
        XCTAssertEqual(KdbSignature.v2(majorFileVersion: 65535, minorFileVersion: 65535), signature2)
    }
}

class KdbSignatureWriterTests: XCTestCase {
    let signatureWriter = KdbSignatureWriter()
    let signatureReader = KdbSignatureReader()

    func testThatWritesSignature() {
        let outStream = DataOutputStream()
        let wroteSignature = KdbSignature(basePrefix:BASE_SIGNATURE_UINT32,
                                     kdbVersion: KDB2_SIGNATURE_UINT32,
                                     fileVersionMajor: 3,
                                     fileVersionMinor: 1)
        XCTAssertNoThrow(try signatureWriter.writeSignature(wroteSignature, outputStream: outStream))

        let inputStream = DataInputStream(withData: outStream.data)
        let readSignature = signatureReader.readSignature(inputStream)
        XCTAssertEqual(readSignature.basePrefix, BASE_SIGNATURE_UINT32)
        XCTAssertEqual(readSignature.kdbVersion, KDB2_SIGNATURE_UINT32)
        XCTAssertEqual(readSignature.fileVersionMajor, 3)
        XCTAssertEqual(readSignature.fileVersionMinor, 1)
    }
}


