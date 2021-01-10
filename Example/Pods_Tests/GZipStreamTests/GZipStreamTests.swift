//
//  GZipStreamTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 2/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class GZipStreamTests: XCTestCase {
    
    func testInOutStreamWith1024Bytes() {
        let data = Data.random(count: 1024)!

        let outputStream = DataOutputStream()
        let gzipOutputStream = try! GZipOutputStream(with: outputStream)
        _ = try! gzipOutputStream.write(data)
        try! gzipOutputStream.close()
        let outData = outputStream.data

        let inputStream = DataInputStream(withData: outData)
        let aesInputStream = try! GZipInputStream(with: inputStream)

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
