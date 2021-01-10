//
//  DatabaseCredentialsStoreTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 3/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class DatabaseCredentialsStoreTests: XCTestCase {
    let credsStore = CredentialsStore()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testWriteAndRead() {
        let path = UUID().uuidString
        let creds = CredentialsStore.CredentialsItem.password("123456789",
                                                                         file: path)
        XCTAssertNoThrow(try credsStore.saveCredentials(creds))
        XCTAssertNoThrow2(try credsStore.fetchCredentials(path)) { (fetched) in
            XCTAssertEqual(creds, fetched)
        }
    }

    func testWriteAndDelete() {
        let path = UUID().uuidString
        let creds = CredentialsStore.CredentialsItem.password("123456789",
                                                                         file: path)
        XCTAssertNoThrow(try credsStore.saveCredentials(creds))
        XCTAssertNoThrow2(try credsStore.fetchCredentials(path)) { (fetched) in
            XCTAssertEqual(creds, fetched)
            XCTAssertNoThrow2( try credsStore.deleteCredentialsForFile(path)) { (fetched) in
                XCTAssertThrowsError(try credsStore.fetchCredentials(path), expectedError: CredentialsStore.KeychainError.noPassword)
            }
        }

    }

}
