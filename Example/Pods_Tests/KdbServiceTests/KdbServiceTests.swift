//
//  KdbServiceTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 11/9/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class KdbServiceTests: XCTestCase {

    func testReadKdbFile() {
        let path = Bundle(for: KdbServiceTests.self).path(forResource: "database_with_delete_entry", ofType: "kdbx")
        XCTAssertNotNil(path)
        let credentials = KdbCredentials.password("database")
        let service = KdbService(path: path!)
        let tree = try! service.openWith(credentials: credentials)
        XCTAssertNotNil(tree)
    }

}
