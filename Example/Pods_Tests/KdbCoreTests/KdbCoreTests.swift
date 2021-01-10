//
//  KdbCoreTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 12/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore


class KdbCoreTests: XCTestCase {

    func testComputeHashFunction() {
        let data = Data([0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x10])
        let result = computeHash(data)
        let expected = Data(hex: "ad6a76c56da2c12c907a42312820d52d6c4e95c1202e6972e39e41f486dddc01")!
        XCTAssertEqual(expected, result)

    }

}
