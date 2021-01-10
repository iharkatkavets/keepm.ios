//
//  MetadataFilesFilterTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 6/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest


class MetadataFilesFilterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testFilteringMetadataFiles() {
        let metaSuffix = ".001"
        let filter = MetadataFilesFilter(metaSuffix: metaSuffix);

        let url1 = URL(string: "http://kotkovets/file1")!
        let item1 = StorageItem(url: url1, isDirectory: false)
        let url1Meta = URL(string: "http://kotkovets/file1".appending(metaSuffix))!
        let item1Meta = StorageItem(url: url1Meta, isDirectory: false)
        let url2 = URL(string: "http://kotkovets/file2")!
        let item2 = StorageItem(url: url2, isDirectory: false)
        let url2Meta = URL(string: "http://kotkovets/file2".appending(metaSuffix))!
        let item2Meta = StorageItem(url: url2Meta, isDirectory: false)

        let all = [item1, item1Meta, item2, item2Meta]

        let filtered = filter.perform(all)

        XCTAssertEqual([item1, item2], filtered)
    }

    func testFilteringMetadataFiles2() {
        let metaSuffix = ".001"
        let filter = MetadataFilesFilter(metaSuffix: metaSuffix);

        let url1 = URL(string: "http://kotkovets/file1")!
        let item1 = StorageItem(url: url1, isDirectory: false)
        let url1Meta = URL(string: "http://kotkovets/file1".appending(metaSuffix))!
        let item1Meta = StorageItem(url: url1Meta, isDirectory: false)
        let url2 = URL(string: "http://kotkovets/file2")!
        let item2 = StorageItem(url: url2, isDirectory: false)
        let url2Meta = URL(string: "http://kotkovets/file2".appending(metaSuffix))!
        let item2Meta = StorageItem(url: url2Meta, isDirectory: false)
        let url3Meta = URL(string: "http://kotkovets/file3".appending(metaSuffix))!
        let item3Meta = StorageItem(url: url3Meta, isDirectory: false)

        let all = [item1, item1Meta, item2, item2Meta, item3Meta]

        let filtered = filter.perform(all)

        XCTAssertEqual([item1, item2, item3Meta], filtered)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
