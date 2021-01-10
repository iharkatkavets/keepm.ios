//
//  Kdb4ReaderTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 10/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class Kdb4ReaderTests: XCTestCase {
    func testThatThrowNotKDBFile() throws {
        let kdbxFileSignature = Data(hex: "00d9 a29a 67fb 4bb5 0100 0300")!
        let inputStream = DataInputStream(withData: kdbxFileSignature)
        let kdbReader = Kdb4Reader(file: inputStream)
        XCTAssertThrowsError(try kdbReader.readSignature(), expectedError: KdbReaderError.readSignatureError)
    }
    
    func testThatThrowUnsupportedKdbVersion() throws {
        let kdbxFileSignature = Data(hex: "03d9 a29a 55fb 4bb5 0100 0300")!
        let inputStream = DataInputStream(withData: kdbxFileSignature)
        let kdbReader = Kdb4Reader(file: inputStream)
        XCTAssertThrowsError(try kdbReader.readSignature(), expectedError: KdbReaderError.unsupportedFileVersion)
    }    
}
