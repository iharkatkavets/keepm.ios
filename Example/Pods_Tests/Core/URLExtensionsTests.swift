//
//  URLExtensionsTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 7/20/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class URLExtensionsTests: XCTestCase {

    func testSubstituteDocumentsPath() {
        let documentsDirURL = AppStorage.documentsDir.url
        let path = "myfile.txt"
        let fullFileURL = documentsDirURL.appendingPathComponent(path)

        let result = fullFileURL.pathWithDeletingDocumentsDir()
        XCTAssertEqual(result, "/" + path)
    }

}
