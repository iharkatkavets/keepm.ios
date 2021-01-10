//
//  AesStreamTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 1/31/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class AesStreamTests: XCTestCase {

    func testReadWrite() {
        let data = Data.random(count: 10000)!

        let iv = Data.random(count: 16)!
        let passwordData = Data.random(count: 32)!

        let outputStream = DataOutputStream()
        let aesOutputStream = try! AesOutputStream(with: outputStream, key: passwordData, vector: iv)
        _ = try! aesOutputStream.write(data)
        try! aesOutputStream.close()
        let outData = outputStream.data

        let inputStream = DataInputStream(withData: outData)
        let aesInputStream = try! AesInputStream(with: inputStream, key: passwordData, vector: iv)

        var inData = Data(count: outData.count)
        let readLen = inData.withUnsafeMutableBytes { (urbp) -> Int in
            let unsafeMutablePointer = urbp.bindMemory(to: UInt8.self).baseAddress!
            return aesInputStream.read(unsafeMutablePointer, maxLength: outData.count)
        }
        inData.removeLast(outData.count-readLen)

        XCTAssertEqual(readLen, data.count)
        XCTAssertEqual(inData, data)
    }

}
