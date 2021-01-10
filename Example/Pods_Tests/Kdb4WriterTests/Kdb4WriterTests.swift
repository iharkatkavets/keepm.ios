//
//  Kdb4WriterTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 1/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class Kdb4WriterTests: XCTestCase {
    let credentials = KdbCredentials.password("AwesomePassword")

    func testWritingSignature1() {
        let params = DatabaseParameters()
        params.fileVersionMajor = 1
        params.fileVersionMinor = 3
        let kdbWriter = try! Kdb4Writer(cachedParameters: params)
        let dataOutputStream = DataOutputStream()
        try! kdbWriter.writeSignature(dataOutputStream)
        let data = dataOutputStream.data

        let kdbxFileSignature = Data(hex: "03D9 A29A 67FB 4BB5 0300 0100")!
        XCTAssertEqual(data,kdbxFileSignature)
    }

    func testWritingSignature2() {
        let params = DatabaseParameters()
        params.fileVersionMajor = 1
        params.fileVersionMinor = 3
        let kdbWriter = try! Kdb4Writer(cachedParameters: params)
        let dataOutputStream = DataOutputStream()
        try! kdbWriter.writeSignature(dataOutputStream)
        let data = dataOutputStream.data

        let inputStream = DataInputStream(withData: data)
        let kdbReader = Kdb4Reader(file: inputStream)
        let signature = try! kdbReader.readSignature()

        XCTAssertEqual(params.fileVersionMajor, signature.fileVersionMajor)
        XCTAssertEqual(params.fileVersionMinor, signature.fileVersionMinor)
    }

    func testWritingHeader() {
        let params = DatabaseParameters()
        let kdbWriter = try! Kdb4Writer(cachedParameters: params)
        let dataOutputStream = DataOutputStream()
        try! kdbWriter.writeHeaders(dataOutputStream)
        let data = dataOutputStream.data

        let inputStream = DataInputStream(withData: data)
        let kdbReader = Kdb4Reader(file: inputStream)
        let readHeaders = try! kdbReader.readHeaders()

        
    }



}
