//
//  KdbHeaderTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 1/13/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class KdbHeaderTests: XCTestCase {

    func testHeaderDataForWriting() {
        var array = Data([0x00,0x01,0x02,0x03])
        let header = KdbHeader(with: .comment, length: 4, data: array)
        
    }



}
