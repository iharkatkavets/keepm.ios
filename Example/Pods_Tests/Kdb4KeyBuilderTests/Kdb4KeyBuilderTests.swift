//
//  Kdb4KeyBuilderTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 1/17/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class Kdb4KeyBuilderTests: XCTestCase {

    // correct
    func testThatCompositeKey() {
        XCTAssertNoThrow ({
            let credentials = TestsConstants.kdbV4Credentials
            let kdbBuilder = Kdb4KeyBuilder()
            let compositeKey = try kdbBuilder.createCompositeKey(with: credentials)
            XCTAssertEqual("18b84ae5b24e651842d52b8fc8e9fef04bab9e3169ae7a3d444be7e691f9a2af",
                             compositeKey.hexString())
        })
    }

    func testThatCreateMasterKey() {
        XCTAssertNoThrow({
            let compositeKey = Data(hex: "18b84ae5b24e651842d52b8fc8e9fef04bab9e3169ae7a3d444be7e691f9a2af")!
            let masterSeed = Data(hex: "6a7f81226e57ec5f958d86aec8d6d35505fb5f09d66ea62702886fbff9016148")!
            let transformSeed = Data(hex: "b99c32c6dd66a3ecd94d4bae80334ede90d4fa0e247de8a0587e72197e1561bb")!
            let kdbBuilder = Kdb4KeyBuilder()
            let masterKey = try kdbBuilder.createMasterKeyWith(compositeKey: compositeKey,
                                                               masterSeed: masterSeed,
                                                               transformSeed: transformSeed,
                                                               rounds: 6000)
            XCTAssertEqual("efc15e4a1566d3d1d2c7fb8a07f921510cd80e6da6c2688c19e55dd02622ae46",
                             masterKey.hexString())
        })
    }

}
