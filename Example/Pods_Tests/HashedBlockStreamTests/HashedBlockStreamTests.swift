





//
//  HashedBlockStreamTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 1/18/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class HashedBlockStreamTests: XCTestCase {

    func testInOutStream1024Bytes() {
        let originData = Data.random(count: 1024)!
        let dataOutStream = DataOutputStream()
        let hashedOutStream = HashedBlockOutputStream(with: dataOutStream)
        _ = try! hashedOutStream.write(originData)
        try! hashedOutStream.close()
        let hashedData = dataOutStream.data

        let dataInputStream = DataInputStream(withData: hashedData)
        let hashedInStream = HashedBlockInputStream(with: dataInputStream)
        var dehashedData = Data(count: hashedData.count)
        let readLen = dehashedData.withUnsafeMutableBytes { (urbp) -> Int in
            let unsafePointer = urbp.bindMemory(to: UInt8.self).baseAddress!
            return hashedInStream.read(unsafePointer, maxLength: hashedData.count)
        }

        dehashedData.removeLast(hashedData.count-readLen)
        XCTAssertEqual(originData.count, readLen)
        XCTAssertEqual(dehashedData, originData)
    }

    func testInOutStream32Bytes() {
        let originData = Data.random(count: 32)!
        let dataOutStream = DataOutputStream()
        let hashedOutStream = HashedBlockOutputStream(with: dataOutStream)
        _ = try! hashedOutStream.write(originData)
        try! hashedOutStream.close()
        let hashedData = dataOutStream.data

        let dataInputStream = DataInputStream(withData: hashedData)
        let hashedInStream = HashedBlockInputStream(with: dataInputStream)
        var dehashedData = Data(count: 32)
        dehashedData.withUnsafeMutableBytes { (urbp) -> Void in
            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
            let unsafePointer = unsafeBufferPointer.baseAddress!
            _ = hashedInStream.read(unsafePointer, maxLength: hashedData.count)
        }

        XCTAssertEqual(dehashedData, originData)
    }

    func testInOutStream1000000Bytes() {
        let originData = Data.random(count: 1000000)!
        let dataOutStream = DataOutputStream()
        let hashedOutStream = HashedBlockOutputStream(with: dataOutStream)
        _ = try! hashedOutStream.write(originData)
        try! hashedOutStream.close()
        let hashedData = dataOutStream.data

        let dataInputStream = DataInputStream(withData: hashedData)
        let hashedInStream = HashedBlockInputStream(with: dataInputStream)
        var dehashedData = Data(count: hashedData.count)
        let readLen = dehashedData.withUnsafeMutableBytes { (urbp) -> Int in
            let unsafePointer = urbp.bindMemory(to: UInt8.self).baseAddress!
            return hashedInStream.read(unsafePointer, maxLength: hashedData.count)
        }

        dehashedData.removeLast(hashedData.count-readLen)
        XCTAssertEqual(originData.count, readLen)
        XCTAssertEqual(dehashedData, originData)
    }

}
