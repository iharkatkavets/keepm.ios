//
//  Salsa20CipherTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 12/30/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class Salsa20CipherTests: XCTestCase {
    let key = Data(bytes: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31])
    let iv = Data(bytes: [0,1,2,3,4,5,6,7])

    func testSalsa20Cipher() {
        let originString = "Salsa20CipherTests.swift"
        let encoder = try! Salsa20Cipher(withKey: key, iv: iv)
        let originStr = Data(bytes: [0x30,0x31,0x32,0x33])
        let outPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: originStr.count)
        originStr.withUnsafeBytes { (urbp) -> Void in
            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
            let unsafePointer = unsafeBufferPointer.baseAddress!
            print(urbp.map {String(format: "%02X", $0)}.joined(separator: " "))
            encoder.xor(input: unsafePointer, output: outPointer, length: originStr.count)
        }

        print("encoded \(outPointer.hexString(ofLength: 4))")


        let decoder = try! Salsa20Cipher(withKey: key, iv: iv)
        let outPointer2 = UnsafeMutablePointer<UInt8>.allocate(capacity: originStr.count)
        decoder.xor(input: outPointer, output: outPointer2, length: originStr.count)
        print("decoded \(outPointer2.hexString(ofLength: 4))")
    }

    func testXorOnBigFile() {
        let encoder = try! Salsa20Cipher(withKey: key, iv: iv)
        let path = Bundle(for: Salsa20CipherTests.self).url(forResource: "BigTextForSalsa", withExtension: "txt")
        let originString = try! String(contentsOf: path!)
        let originStr = originString.data(using: .utf8)!
        let outPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: originStr.count)
        originStr.withUnsafeBytes { (urbp) -> Void in
            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
            let unsafePointer = unsafeBufferPointer.baseAddress!
            print(urbp.map {String(format: "%02X", $0)}.joined(separator: " "))
            encoder.xor(input: unsafePointer, output: outPointer, length: originStr.count)
        }

        print("encoded \(outPointer.hexString(ofLength: 4))")


        let decoder = try! Salsa20Cipher(withKey: key, iv: iv)
        let outPointer2 = UnsafeMutablePointer<UInt8>.allocate(capacity: originStr.count)
        decoder.xor(input: outPointer, output: outPointer2, length: originStr.count)
        print("decoded \(outPointer2.hexString(ofLength: 4))")
        let stringToCheck = String(bytesNoCopy: outPointer2, length: originStr.count, encoding: .utf8, freeWhenDone: false)
        XCTAssertEqual(originString, stringToCheck)
    }
}
